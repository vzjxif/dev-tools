import SwiftUI

@main
struct DevToolsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.purple) // 全局强调色
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
        }
    }
}
