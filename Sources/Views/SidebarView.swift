import SwiftUI

struct SidebarView: View {
    @Binding var selectedTool: ToolType?
    @State private var searchText = ""
    
    var filteredTools: [ToolType] {
        if searchText.isEmpty {
            return ToolType.allCases
        } else {
            return ToolType.allCases.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List(selection: $selectedTool) {
            ForEach(filteredTools) { tool in
                NavigationLink(value: tool) {
                    Label(tool.name, systemImage: tool.icon)
                        .padding(.vertical, 4) // 增加一点高度，显得更宽松
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("DevTools")
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search...")
    }
}
