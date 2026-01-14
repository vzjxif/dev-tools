import SwiftUI

struct JWTToolView: View {
    @StateObject private var viewModel = JWTToolViewModel()
    
    var body: some View {
        HSplitView {
            // Input
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Encoded Token") {
                    Button(action: viewModel.pasteFromClipboard) {
                        Label("Clipboard", systemImage: "doc.on.clipboard")
                    }
                    Button("Clear", action: viewModel.clear)
                }
                
                MacEditorView(text: $viewModel.input, isEditable: true)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
            
            // Output
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Decoded Body") {
                    Text("Header / Payload / Signature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Header")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            MacEditorView(text: .constant(viewModel.header), isEditable: false)
                                .frame(height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Payload
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payload")
                                .font(.headline)
                                .foregroundColor(.purple)
                            MacEditorView(text: .constant(viewModel.payload), isEditable: false)
                                .frame(minHeight: 350)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Signature
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Signature")
                                .font(.headline)
                                .foregroundColor(.blue)
                            MacEditorView(text: .constant(viewModel.signature), isEditable: false)
                                .frame(height: 60)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding()
                }
                .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.textBackgroundColor))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .frame(maxWidth: .infinity)
                }
            }
            .layoutPriority(1)
        }
    }
}
