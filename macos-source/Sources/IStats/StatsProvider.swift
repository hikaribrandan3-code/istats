// StatsProvider — polls CPU / RAM / network / disk / top processes on a
// timer and publishes values for the SwiftUI popovers. Everything reads
// straight from Mach / BSD APIs; nothing leaves the machine.
import Foundation
import Darwin
import AppKit

struct ProcessStat: Identifiable {
    let id: Int32 // pid
    let name: String
    let cpuPercent: Double
    let ramBytes: UInt64
    let icon: NSImage?
}

struct DiskVolume: Identifiable {
    let id: String // mount path
    let name: String
    let available: UInt64
    let total: UInt64
}

final class StatsProvider: ObservableObject {
    static let historyLength = 60

    @Published var cpuUsage: Double = 0            // 0...100, all cores combined
    @Published var perCoreUsage: [Double] = []     // 0...100 each
    @Published var cpuHistory: [Double] = []
    @Published var topCPUProcesses: [ProcessStat] = []

    @Published var ramUsed: UInt64 = 0
    @Published var ramCached: UInt64 = 0
    @Published var ramFree: UInt64 = 0
    @Published var ramTotal: UInt64 = ProcessInfo.processInfo.physicalMemory
    @Published var ramHistory: [Double] = []       // estimated used fraction 0...1
    @Published var topRAMProcesses: [ProcessStat] = []

    @Published var networkDown: UInt64 = 0         // bytes/sec
    @Published var networkUp: UInt64 = 0
    @Published var downHistory: [Double] = []
    @Published var upHistory: [Double] = []
    @Published var interfaceName: String = "—"
    @Published var localIP: String = "—"

    @Published var volumes: [DiskVolume] = []

    private var timer: Timer?
    private(set) var interval: TimeInterval = 2.0

    // Previous samples for delta-based metrics
    private var prevCPUTicks: [[UInt32]] = []              // per core [user, system, idle, nice]
    private var prevNetBytes: (down: UInt64, up: UInt64)?
    private var prevNetInterface: String?
    private var prevNetSample: Date?
    private var prevProcTime: [Int32: UInt64] = [:]        // pid -> total ns
    private var prevProcSample: Date?

    func start(interval: TimeInterval) {
        self.interval = interval
        timer?.invalidate()
        tick()
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        updateCPU()
        updateRAM()
        updateNetwork()
        updateDisk()
        updateTopProcesses()
    }

    // MARK: - CPU

    private func updateCPU() {
        var count: natural_t = 0
        var info: processor_info_array_t?
        var infoCount: mach_msg_type_number_t = 0
        guard host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &count, &info, &infoCount) == KERN_SUCCESS,
              let info else { return }
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(infoCount) * vm_size_t(MemoryLayout<integer_t>.size))
        }

        var ticks: [[UInt32]] = []
        for core in 0..<Int(count) {
            let base = core * Int(CPU_STATE_MAX)
            let user = UInt32(bitPattern: info[base + Int(CPU_STATE_USER)])
            let system = UInt32(bitPattern: info[base + Int(CPU_STATE_SYSTEM)])
            let idle = UInt32(bitPattern: info[base + Int(CPU_STATE_IDLE)])
            let nice = UInt32(bitPattern: info[base + Int(CPU_STATE_NICE)])
            ticks.append([user, system, idle, nice])
        }

        if prevCPUTicks.count == ticks.count {
            var perCore: [Double] = []
            for (now, prev) in zip(ticks, prevCPUTicks) {
                let user = Double(now[0] &- prev[0])
                let system = Double(now[1] &- prev[1])
                let idle = Double(now[2] &- prev[2])
                let nice = Double(now[3] &- prev[3])
                let total = user + system + idle + nice
                perCore.append(total > 0 ? (user + system + nice) / total * 100 : 0)
            }
            perCoreUsage = perCore
            cpuUsage = perCore.isEmpty ? 0 : perCore.reduce(0, +) / Double(perCore.count)
            push(&cpuHistory, cpuUsage)
        }
        prevCPUTicks = ticks
    }

    // MARK: - RAM

    private func updateRAM() {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        guard result == KERN_SUCCESS else { return }

        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(stats.active_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize
        let free = UInt64(stats.free_count) * pageSize

        // These VM page classes are only an estimate of memory composition;
        // they are not Apple's memory-pressure metric or Activity Monitor's
        // exact categories. Keep the displayed segments bounded by total RAM.
        ramUsed = min(active + wired + compressed, ramTotal)
        ramFree = min(free, ramTotal - ramUsed)
        ramCached = ramTotal - ramUsed - ramFree // remaining cache/other pages
        push(&ramHistory, ramTotal > 0 ? Double(ramUsed) / Double(ramTotal) : 0)
    }

    // MARK: - Network

    private func updateNetwork() {
        var addrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrs) == 0, let first = addrs else { return }
        defer { freeifaddrs(addrs) }

        var counters: [String: (down: UInt64, up: UInt64)] = [:]
        var ipv4: [(name: String, address: String)] = []

        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let ifa = cursor {
            let name = String(cString: ifa.pointee.ifa_name)
            let flags = Int32(ifa.pointee.ifa_flags)
            let isUp = (flags & IFF_UP) != 0 && (flags & IFF_RUNNING) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0

            if let addr = ifa.pointee.ifa_addr, isUp, !isLoopback {
                if addr.pointee.sa_family == UInt8(AF_LINK) {
                    if let data = ifa.pointee.ifa_data?.assumingMemoryBound(to: if_data.self) {
                        counters[name] = (UInt64(data.pointee.ifi_ibytes), UInt64(data.pointee.ifi_obytes))
                    }
                }
                if addr.pointee.sa_family == UInt8(AF_INET),
                   name.hasPrefix("en") || name.hasPrefix("pdp") || name.hasPrefix("utun") {
                    var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 {
                        let address = String(cString: host)
                        if !address.hasPrefix("169.254.") && address != "0.0.0.0" {
                            ipv4.append((name, address))
                        }
                    }
                }
            }
            cursor = ifa.pointee.ifa_next
        }

        func priority(_ name: String) -> Int {
            if name == "en0" { return 0 }
            if name.hasPrefix("en") { return 1 }
            if name.hasPrefix("pdp") { return 2 }
            return 3
        }
        let selected = ipv4.sorted { priority($0.name) < priority($1.name) }.first
        let activeInterface = selected?.name ?? "—"
        let ip = selected?.address ?? "—"
        let bytes = counters[activeInterface] ?? (0, 0)
        let now = Date()
        if let prev = prevNetBytes, prevNetInterface == activeInterface,
           let previousTime = prevNetSample, now.timeIntervalSince(previousTime) > 0.1 {
            let dDown = bytes.down >= prev.down ? bytes.down - prev.down : 0
            let dUp = bytes.up >= prev.up ? bytes.up - prev.up : 0
            let elapsed = now.timeIntervalSince(previousTime)
            networkDown = UInt64(Double(dDown) / elapsed)
            networkUp = UInt64(Double(dUp) / elapsed)
        } else {
            networkDown = 0
            networkUp = 0
        }
        push(&downHistory, Double(networkDown))
        push(&upHistory, Double(networkUp))
        prevNetBytes = bytes
        prevNetInterface = activeInterface
        prevNetSample = now
        interfaceName = activeInterface
        localIP = ip
    }

    // MARK: - Disk

    private func updateDisk() {
        let keys: Set<URLResourceKey> = [.volumeNameKey, .volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeIsBrowsableKey, .volumeIsLocalKey]
        let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: Array(keys), options: [.skipHiddenVolumes]) ?? []
        var result: [DiskVolume] = []
        for url in urls {
            guard let values = try? url.resourceValues(forKeys: keys),
                  values.volumeIsLocal == true,
                  values.volumeIsBrowsable == true,
                  let total = values.volumeTotalCapacity, total > 0,
                  let availableCapacity = values.volumeAvailableCapacity else { continue }
            let available = UInt64(max(0, min(availableCapacity, total)))
            result.append(DiskVolume(
                id: url.path,
                name: values.volumeName ?? url.lastPathComponent,
                available: available,
                total: UInt64(total)
            ))
        }
        // Root volume first, then by size
        volumes = result.sorted { a, b in
            if a.id == "/" { return true }
            if b.id == "/" { return false }
            return a.total > b.total
        }
    }

    // MARK: - Top processes

    private func updateTopProcesses() {
        let pidCount = proc_listallpids(nil, 0)
        guard pidCount > 0 else { return }
        var pids = [Int32](repeating: 0, count: Int(pidCount) * 2)
        let filled = proc_listallpids(&pids, Int32(pids.count) * Int32(MemoryLayout<Int32>.size))
        guard filled > 0 else { return }

        let now = Date()
        let elapsed = prevProcSample.map { now.timeIntervalSince($0) } ?? interval
        var newTimes: [Int32: UInt64] = [:]
        var stats: [ProcessStat] = []
        let runningApps = NSWorkspace.shared.runningApplications

        for pid in pids.prefix(Int(filled)) where pid > 0 {
            var info = proc_taskinfo()
            let size = Int32(MemoryLayout<proc_taskinfo>.size)
            guard proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, size) == size else { continue }

            let totalNs = info.pti_total_user &+ info.pti_total_system
            newTimes[pid] = totalNs

            var cpuPercent = 0.0
            if let prev = prevProcTime[pid], totalNs >= prev, elapsed > 0 {
                cpuPercent = Double(totalNs - prev) / (elapsed * 1_000_000_000) * 100
            }

            var nameBuf = [CChar](repeating: 0, count: 256)
            proc_name(pid, &nameBuf, UInt32(nameBuf.count))
            let name = String(cString: nameBuf)
            guard !name.isEmpty else { continue }

            let app = runningApps.first { $0.processIdentifier == pid }
            stats.append(ProcessStat(
                id: pid,
                name: app?.localizedName ?? name,
                cpuPercent: cpuPercent,
                ramBytes: info.pti_resident_size,
                icon: app?.icon
            ))
        }

        prevProcTime = newTimes
        prevProcSample = now
        topCPUProcesses = Array(stats.sorted { $0.cpuPercent > $1.cpuPercent }.prefix(5))
        topRAMProcesses = Array(stats.sorted { $0.ramBytes > $1.ramBytes }.prefix(5))
    }

    // MARK: - Helpers

    private func push(_ history: inout [Double], _ value: Double) {
        history.append(value)
        if history.count > Self.historyLength {
            history.removeFirst(history.count - Self.historyLength)
        }
    }
}

// MARK: - Formatting helpers shared by widgets + popovers

enum Fmt {
    static func bytes(_ value: UInt64) -> String {
        let f = ByteCountFormatter()
        f.countStyle = .memory
        f.allowsNonnumericFormatting = false
        return f.string(fromByteCount: Int64(value))
    }

    static func speed(_ bytesPerSec: UInt64) -> String {
        if bytesPerSec >= 1_048_576 {
            return String(format: "%.1f MiB/s", Double(bytesPerSec) / 1_048_576)
        }
        if bytesPerSec >= 1_024 {
            return String(format: "%.0f KiB/s", Double(bytesPerSec) / 1_024)
        }
        return "\(bytesPerSec) B/s"
    }

    static func gigabytes(_ value: UInt64) -> String {
        String(format: "%.1f GiB", Double(value) / 1_073_741_824)
    }
}
