// Simple translation system for iStats (English + Spanish)
import Foundation

enum Language: String, CaseIterable, Identifiable {
    case en = "English"
    case es = "Español"

    var id: String { rawValue }
}

struct Strings {
    static func get(_ key: String, lang: Language) -> String {
        let table: [String: [Language: String]] = [
            // SettingsView
            "settings.updateInterval": [
                .en: "UPDATE INTERVAL",
                .es: "INTERVALO DE ACTUALIZACIÓN",
            ],
            "settings.launch": [
                .en: "LAUNCH",
                .es: "INICIO",
            ],
            "settings.launchAtLogin": [
                .en: "Launch iStats at Login",
                .es: "Abrir iStats al iniciar",
            ],
            "settings.power": [
                .en: "power",
                .es: "power",
            ],
            "settings.quit": [
                .en: "Quit iStats",
                .es: "Salir de iStats",
            ],
            "settings.version": [
                .en: "iStats • iSuite Office",
                .es: "iStats • iSuite Office",
            ],

            // DashboardView / Panels
            "panel.cpu": [
                .en: "CPU",
                .es: "CPU",
            ],
            "panel.memory": [
                .en: "Memory",
                .es: "Memoria",
            ],
            "panel.network": [
                .en: "Network",
                .es: "Red",
            ],
            "panel.disk": [
                .en: "Disk",
                .es: "Disco",
            ],

            // CPU Panel
            "cpu.history": [
                .en: "Last 60 samples",
                .es: "Últimas 60 muestras",
            ],
            "cpu.topProcesses": [
                .en: "TOP PROCESSES",
                .es: "PROCESOS PRINCIPALES",
            ],

            // Memory Panel
            "memory.used": [
                .en: "Used (estimate)",
                .es: "Usado (estimado)",
            ],
            "memory.cached": [
                .en: "Other / cache",
                .es: "Otros / caché",
            ],
            "memory.free": [
                .en: "Free pages",
                .es: "Páginas libres",
            ],
            "memory.total": [
                .en: "Total",
                .es: "Total",
            ],
            "memory.history": [
                .en: "Last 60 samples",
                .es: "Últimas 60 muestras",
            ],
            "memory.topProcesses": [
                .en: "TOP PROCESSES",
                .es: "PROCESOS PRINCIPALES",
            ],

            // Network Panel
            "network.download": [
                .en: "Download",
                .es: "Descarga",
            ],
            "network.upload": [
                .en: "Upload",
                .es: "Subida",
            ],
            "network.interface": [
                .en: "Sampled Interface",
                .es: "Interfaz medida",
            ],
            "network.ip": [
                .en: "Local IP",
                .es: "IP Local",
            ],

            // Disk Panel
            "disk.used": [
                .en: "Used / reserved",
                .es: "Usado / reservado",
            ],
            "disk.free": [
                .en: "Available",
                .es: "Disponible",
            ],
            "disk.total": [
                .en: "Total",
                .es: "Total",
            ],
        ]

        return table[key]?[lang] ?? key
    }
}
