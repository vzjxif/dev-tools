import SwiftUI

struct Base64ToolView: View {
    @StateObject private var viewModel = Base64ToolViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Input") {
                    Picker("", selection: $viewModel.mode) {
                        ForEach(Base64Service.Mode.allCases) { mode in
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
                
                ZStack(alignment: .topLeading) {
                    MacEditorView(text: .constant(viewModel.output), isEditable: false)
                        .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(4)
                            .padding()
                    }
                }
            }
            .layoutPriority(1)
        }
    }
}
