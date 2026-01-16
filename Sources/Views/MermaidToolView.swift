import SwiftUI

struct MermaidToolView: View {
    @StateObject private var viewModel = MermaidToolViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Mermaid Syntax") {
                    Button("Reset", action: viewModel.clear)
                }
                
                MacEditorView(text: $viewModel.input, isEditable: true)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Preview") {
                    Text("Rendered via Mermaid.js")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GenericWebView(htmlContent: viewModel.htmlContent)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
        }
    }
}
