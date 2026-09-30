// Popover panels shown when a menu bar widget is clicked.
// Matches the iSuite design language: white panels, one accent per metric
// (blue CPU, purple RAM, green/orange network, gray disk), SF Pro, rounded.
import SwiftUI
import Charts

private struct PanelHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HistoryChart: View {
    let values: [Double]
    let color: Color
    var maxValue: Double? = nil

    var body: some View {
        Chart(Array(values.enumerated()), id: \.offset) { item in
            AreaMark(x: .value("t", item.offset), y: .value("v", item.element))
                .foregroundStyle(color.opacity(0.15))
            LineMark(x: .value("t", item.offset), y: .value("v", item.element))
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: 0...max(StatsProvider.historyLength - 1, 1))
        .chartYScale(domain: 0...(maxValue ?? max(values.max() ?? 1, 1)))
        .frame(height: 44)
    }
}

private struct ProcessRow: View {
    let stat: ProcessStat
    let trailing: String

    var body: some View {
        HStack(spacing: 8) {
            if let icon = stat.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
            }
            Text(stat.name)
                .font(.system(size: 12))
                .lineLimit(1)
            Spacer()
            Text(trailing)
                .font(.system(size: 12, weight: .medium).monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - CPU

struct CPUPanel: View {
    @ObservedObject var stats: StatsProvider
    var language: Language = .en

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: Strings.get("panel.cpu", lang: language))

            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: min(stats.cpuUsage / 100, 1))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(stats.cpuUsage))%")
                        .font(.system(size: 22, weight: .bold).monospacedDigit())
                }
                .frame(width: 88, height: 88)
                Spacer()
            }

            HistoryChart(values: stats.cpuHistory, color: .blue, maxValue: 100)
            Text(Strings.get("cpu.history", lang: language))
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            Text(Strings.get("cpu.topProcesses", lang: language))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
            ForEach(stats.topCPUProcesses) { p in
                ProcessRow(stat: p, trailing: String(format: "%.0f%%", p.cpuPercent))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - RAM

struct RAMPanel: View {
    @ObservedObject var stats: StatsProvider
    var language: Language = .en

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: Strings.get("panel.memory", lang: language))

            let used = Double(stats.ramUsed)
            let cached = Double(stats.ramCached)
            let total = Double(stats.ramTotal)
            let free = max(total - used - cached, 0)

            GeometryReader { geo in
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue)
                        .frame(width: geo.size.width * used / total)
                    Rectangle().fill(Color.blue.opacity(0.5))
                        .frame(width: geo.size.width * cached / total)
                    Rectangle().fill(Color.blue.opacity(0.15))
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .frame(height: 18)

            VStack(alignment: .leading, spacing: 4) {
                legendRow(color: .blue, label: Strings.get("memory.used", lang: language), value: Fmt.gigabytes(stats.ramUsed))
                legendRow(color: .blue.opacity(0.5), label: Strings.get("memory.cached", lang: language), value: Fmt.gigabytes(stats.ramCached))
                legendRow(color: .blue.opacity(0.15), label: Strings.get("memory.free", lang: language), value: Fmt.gigabytes(UInt64(free)))
            }

            Text("\(Strings.get("memory.total", lang: language)) \(Fmt.gigabytes(stats.ramTotal))")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            HistoryChart(values: stats.ramHistory, color: .purple, maxValue: 1)
            Text(Strings.get("memory.history", lang: language))
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            Text(Strings.get("memory.topProcesses", lang: language))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
            ForEach(stats.topRAMProcesses) { p in
                ProcessRow(stat: p, trailing: Fmt.gigabytes(p.ramBytes))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func legendRow(color: Color, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 10)
            Text(label).font(.system(size: 12))
            Spacer()
            Text(value).font(.system(size: 12, weight: .medium).monospacedDigit())
        }
    }
}

// MARK: - Network

struct NetworkPanel: View {
    @ObservedObject var stats: StatsProvider
    var language: Language = .en

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: Strings.get("panel.network", lang: language))

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.get("network.download", lang: language))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.green)
                    HistoryChart(values: stats.downHistory, color: .green)
                    Label(Fmt.speed(stats.networkDown), systemImage: "arrow.down")
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundStyle(.green)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.get("network.upload", lang: language))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.orange)
                    HistoryChart(values: stats.upHistory, color: .orange)
                    Label(Fmt.speed(stats.networkUp), systemImage: "arrow.up")
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundStyle(.orange)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 3) {
                Text("\(Strings.get("network.interface", lang: language)): \(stats.interfaceName)")
                Text("\(Strings.get("network.ip", lang: language)): \(stats.localIP)")
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Disk

struct DiskPanel: View {
    @ObservedObject var stats: StatsProvider
    var language: Language = .en

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PanelHeader(title: Strings.get("panel.disk", lang: language))

            ForEach(stats.volumes) { vol in
                VStack(alignment: .leading, spacing: 5) {
                    Text(vol.name)
                        .font(.system(size: 12, weight: .medium))

                    let usedFraction = vol.total > 0 ? Double(vol.total - vol.free) / Double(vol.total) : 0
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.15))
                            RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.6))
                                .frame(width: geo.size.width * usedFraction)
                        }
                    }
                    .frame(height: 14)

                    HStack {
                        Text("\(Strings.get("disk.used", lang: language)) \(Fmt.gigabytes(vol.total - vol.free))")
                        Spacer()
                        Text("\(Strings.get("disk.free", lang: language)) \(Fmt.gigabytes(vol.free))")
                    }
                    .font(.system(size: 11).monospacedDigit())
                    .foregroundStyle(.secondary)

                    Text("\(Strings.get("disk.total", lang: language)) \(Fmt.gigabytes(vol.total))")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                if vol.id != stats.volumes.last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
