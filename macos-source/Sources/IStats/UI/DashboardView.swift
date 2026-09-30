// Main iStats window — a 2x2 dashboard showing CPU, Memory, Network, and
// Disk all at once, each in its own card. Same panels used to power the
// (optional) menu bar quick-glance, just laid out for a real window.
import SwiftUI

private struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.gray.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
    }
}

struct DashboardView: View {
    @ObservedObject var stats: StatsProvider
    @AppStorage(Prefs.language) private var languageRaw = "en"

    private var language: Language {
        Language(rawValue: languageRaw) ?? .en
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                Card { CPUPanel(stats: stats, language: language) }
                Card { RAMPanel(stats: stats, language: language) }
                Card { NetworkPanel(stats: stats, language: language) }
                Card { DiskPanel(stats: stats, language: language) }
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 700, minHeight: 560)
    }
}
