// iStats — free, local system monitor. Regular windowed Mac app (Dock icon,
// appears in Applications/Spotlight/Launchpad), with a small menu bar quick
// -open extra as a convenience, matching the rest of the iSuite apps.
import AppKit
import SwiftUI

@main
struct IStatsApp: App {
    @StateObject private var stats = StatsProvider()

    init() {
        Prefs.registerDefaults()
    }

    var body: some Scene {
        Window("iStats", id: "main") {
            DashboardView(stats: stats)
                .onAppear {
                    let interval = UserDefaults.standard.double(forKey: Prefs.updateInterval)
                    stats.start(interval: interval > 0 ? interval : 2.0)
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 760, height: 620)

        Settings {
            SettingsView()
        }

        MenuBarExtra {
            MenuBarContent()
        } label: {
            Image(systemName: "gauge.with.dots.needle.67percent")
        }
    }
}

private struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open iStats") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        Button("Quit iStats") {
            NSApp.terminate(nil)
        }
    }
}
