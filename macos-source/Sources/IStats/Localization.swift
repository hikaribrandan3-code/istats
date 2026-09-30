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
                .en: "v1.0 Summer 2026 • iSuite Office",
                .es: "v1.0 Verano 2026 • iSuite Office",
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
                .en: "Last 60 seconds",
                .es: "Últimos 60 segundos",
            ],
            "cpu.topProcesses": [
                .en: "TOP PROCESSES",
                .es: "PROCESOS PRINCIPALES",
            ],

            // Memory Panel
            "memory.used": [
                .en: "Used",
                .es: "Usado",
            ],
            "memory.cached": [
                .en: "Cached",
                .es: "En caché",
            ],
            "memory.free": [
                .en: "Free",
                .es: "Libre",
            ],
            "memory.total": [
                .en: "Total",
                .es: "Total",
            ],
            "memory.history": [
                .en: "Last 60 seconds",
                .es: "Últimos 60 segundos",
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
                .en: "Active Interface",
                .es: "Interfaz Activa",
            ],
            "network.ip": [
                .en: "Local IP",
                .es: "IP Local",
            ],

            // Disk Panel
            "disk.used": [
                .en: "Used",
                .es: "Usado",
            ],
            "disk.free": [
                .en: "Free",
                .es: "Libre",
            ],
            "disk.total": [
                .en: "Total",
                .es: "Total",
            ],
        ]

        return table[key]?[lang] ?? key
    }
}
