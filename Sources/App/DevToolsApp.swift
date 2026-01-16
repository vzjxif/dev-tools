import SwiftUI

@main
struct DevToolsApp: App {
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .tint(.purple) 
                .injectOpenWindow(openWindow)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
        }
        
        MenuBarExtra("DevTools", systemImage: "hammer.circle.fill") {
            Button("Open DevTools") {
                let mainWindow = NSApp.windows.first { window in
                    return window.title == "DevTools" && !(window is NSPanel)
                }
                
                if let mainWin = mainWindow {
                    mainWin.makeKeyAndOrderFront(nil)
                } else {
                    openWindow(id: "main")
                }
                NSApp.activate(ignoringOtherApps: true)
            }
            Divider()
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("Settings...")
                }
            } else {
                Button("Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}

private struct OpenWindowInjector: ViewModifier {
    let action: OpenWindowAction
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                SettingsManager.shared.openMainWindowAction = {
                    action(id: "main")
                }
            }
    }
}

extension View {
    func injectOpenWindow(_ action: OpenWindowAction) -> some View {
        modifier(OpenWindowInjector(action: action))
    }
}
