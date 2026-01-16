import SwiftUI

struct ContentView: View {
    @State private var selectedTool: ToolType? = .jsonFormatter
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTool: $selectedTool)
        } detail: {
            if let tool = selectedTool {
                switch tool {
                case .jsonFormatter:
                    JSONToolView()
                case .base64:
                    Base64ToolView()
                case .jwt:
                    JWTToolView()
                case .unixTime:
                    UnixTimeToolView()
                case .url:
                    URLToolView()
                case .hash:
                    HashToolView()
                case .mermaid:
                    MermaidToolView()
                }
            } else {
                Text("Select a tool from the sidebar")
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchTool"))) { notification in
            if let tool = notification.object as? ToolType {
                selectedTool = tool
            }
        }
    }
}
