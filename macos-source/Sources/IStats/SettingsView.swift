// iStats Settings — update interval + launch at login + language.
import SwiftUI
import ServiceManagement

enum Prefs {
    static let updateInterval = "updateInterval"
    static let language = "language"

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            updateInterval: 2.0,
            language: "en",
        ])
    }
}

struct SettingsView: View {
    @AppStorage(Prefs.updateInterval) private var updateInterval = 2.0
    @AppStorage(Prefs.language) private var languageRaw = "en"
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    private var language: Language {
        Language(rawValue: languageRaw) ?? .en
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel(Strings.get("settings.updateInterval", lang: language))
                Picker("", selection: $updateInterval) {
                    Text("1s").tag(1.0)
                    Text("2s").tag(2.0)
                    Text("5s").tag(5.0)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionLabel(Strings.get("settings.launch", lang: language))
                Toggle(isOn: $launchAtLogin) { widgetLabel("power", Strings.get("settings.launchAtLogin", lang: language)) }
                    .onChange(of: launchAtLogin) { _, enabled in
                        do {
                            if enabled {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("LANGUAGE")
                Picker("", selection: $languageRaw) {
                    ForEach(Language.allCases, id: \.id) { lang in
                        Text(lang.rawValue).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Spacer()

            VStack(alignment: .center) {
                Text(Strings.get("settings.version", lang: language))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .toggleStyle(.switch)
        .controlSize(.small)
        .padding(20)
        .frame(width: 320, alignment: .topLeading)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .tracking(0.5)
    }

    private func widgetLabel(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12))
                .foregroundStyle(.blue)
                .frame(width: 18)
            Text(text)
                .font(.system(size: 13))
        }
    }
}
