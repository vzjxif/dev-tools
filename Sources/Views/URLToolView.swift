import SwiftUI

struct URLToolView: View {
    @StateObject private var viewModel = URLToolViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Input") {
                    Picker("", selection: $viewModel.mode) {
                        ForEach(URLService.Mode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    
                    Button(action: viewModel.pasteFromClipboard) {
                        Label("Clipboard", systemImage: "doc.on.clipboard")
                    }
                    Button("Clear", action: viewModel.clear)
                }
                
                MacEditorView(text: $viewModel.input, isEditable: true)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Output") {
                    Button(action: viewModel.copyOutput) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .disabled(viewModel.output.isEmpty)
                }
                
                MacEditorView(text: .constant(viewModel.output), isEditable: false)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
        }
    }
}
