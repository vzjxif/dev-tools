import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager = SettingsManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Active Tools (Drag to reorder)")) {
                    ForEach(manager.activeTools) { tool in
                        HStack {
                            Image(systemName: tool.icon)
                                .frame(width: 20)
                            Text(tool.name)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    manager.toggleTool(tool)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onMove { indices, newOffset in
                        manager.moveActive(from: indices, to: newOffset)
                    }
                }
                
                if !manager.disabledTools.isEmpty {
                    Section(header: Text("Disabled Tools")) {
                        ForEach(manager.disabledTools) { tool in
                            HStack {
                                Image(systemName: tool.icon)
                                    .frame(width: 20)
                                Text(tool.name)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        manager.toggleTool(tool)
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
        .frame(width: 450, height: 400)
        .padding()
    }
}
