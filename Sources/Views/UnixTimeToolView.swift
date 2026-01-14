import SwiftUI

struct UnixTimeToolView: View {
    @StateObject private var viewModel = UnixTimeToolViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Unix Timestamp") {
                    Picker("", selection: $viewModel.timeUnit) {
                        ForEach(UnixTimeToolViewModel.TimeUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    
                    Button("Now", action: viewModel.setToNow)
                    Button(action: viewModel.copyTimestamp) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
                
                ZStack {
                    Color(NSColor.textBackgroundColor)
                    TextField("Timestamp", text: $viewModel.timestampInput)
                        .font(.system(size: 24, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding()
                }
                .frame(height: 100)
                
                Divider()
            }
            
            HStack {
                Divider()
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(NSColor.windowBackgroundColor))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                Divider()
            }
            .frame(height: 40)
            .background(Color(NSColor.windowBackgroundColor))
            
            VStack(spacing: 0) {
                ToolSectionHeader(title: "Date (yyyy-MM-dd HH:mm:ss)") {
                    Button(action: viewModel.copyDate) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
                
                ZStack {
                    Color(NSColor.textBackgroundColor)
                    TextField("Date string", text: $viewModel.dateInput)
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding()
                }
                .frame(height: 80)
                
                Divider()
                
                List {
                    Section(header: Text("Common Formats")) {
                        ForEach(viewModel.otherFormats) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.label)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(item.value)
                                        .font(.system(.body, design: .monospaced))
                                        .textSelection(.enabled)
                                }
                                Spacer()
                                Button(action: {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(item.value, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
    }
}
