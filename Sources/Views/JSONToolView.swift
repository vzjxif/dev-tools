import SwiftUI

struct JSONToolView: View {
    @StateObject private var viewModel = JSONToolViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Input") {
                    Button(action: viewModel.pasteFromClipboard) {
                        Label("Clipboard", systemImage: "doc.on.clipboard")
                    }
                    Button(action: viewModel.unescapeInput) {
                        Label("Unescape", systemImage: "text.quote")
                    }
                    Button("Sample") {
                        viewModel.input = "{\"hello\": \"world\", \"foo\": [1, 2, 3]}"
                    }
                    Button("Clear", action: viewModel.clear)
                }
                
                MacEditorView(text: $viewModel.input, isEditable: true)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Output") {
                    Picker("", selection: $viewModel.indentation) {
                        ForEach(JSONService.Indentation.allCases) { indent in
                            Text(indent.description).tag(indent)
                        }
                    }
                    .frame(width: 100)
                    .labelsHidden()
                    
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
