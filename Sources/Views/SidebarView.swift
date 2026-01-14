import SwiftUI

struct SidebarView: View {
    @Binding var selectedTool: ToolType?
    @State private var searchText = ""
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var filteredTools: [ToolType] {
        let tools = settingsManager.activeTools
        if searchText.isEmpty {
            return tools
        } else {
            return tools.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List(selection: $selectedTool) {
            ForEach(filteredTools) { tool in
                NavigationLink(value: tool) {
                    Label(tool.name, systemImage: tool.icon)
                        .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("DevTools")
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search...")
    }
}
