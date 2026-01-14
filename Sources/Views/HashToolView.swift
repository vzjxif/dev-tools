import SwiftUI

struct HashToolView: View {
    @StateObject private var viewModel = HashToolViewModel()
    
    var body: some View {
        HSplitView {
            // Input Area
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Input Text") {
                    Button("Clear", action: viewModel.clear)
                }
                
                MacEditorView(text: $viewModel.input, isEditable: true)
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            .layoutPriority(1)
            
            // Output Area
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Hashes") {
                    // Placeholder for future actions
                }
                
                List {
                    if viewModel.results.isEmpty {
                        Text("Enter text to generate hashes")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(viewModel.results, id: \.algorithm) { result in
                            HashResultRow(result: result)
                        }
                    }
                }
            }
            .layoutPriority(1)
        }
    }
}

struct HashResultRow: View {
    let result: HashService.HashResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.algorithm)
                .font(.headline)
            
            HashValueRow(label: "Hex", value: result.hex)
            HashValueRow(label: "Base64", value: result.base64)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}

struct HashValueRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(value, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .help("Copy \(label)")
        }
    }
}
