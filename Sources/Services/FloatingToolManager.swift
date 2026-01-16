import SwiftUI
import AppKit

class FloatingToolManager: ObservableObject {
    static let shared = FloatingToolManager()
    
    private var windowController: NSWindowController?
    
    func show(tool: ToolType) {
        if let existing = windowController {
            existing.close()
            windowController = nil
        }
        
        let toolView = FloatingToolContainer(tool: tool)
            .frame(minWidth: 600, minHeight: 400)
            .background(Color(NSColor.windowBackgroundColor))
        
        let hostingController = NSHostingController(rootView: toolView)
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        panel.title = tool.name
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.level = .floating 
        panel.contentViewController = hostingController
        
        if let screen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }) ?? NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowWidth: CGFloat = 600
            let windowHeight: CGFloat = 400
            
            let x = screenRect.origin.x + (screenRect.width - windowWidth) / 2
            let y = screenRect.origin.y + (screenRect.height - windowHeight) / 2
            
            let centeredRect = NSRect(x: x, y: y, width: windowWidth, height: windowHeight)
            panel.setFrame(centeredRect, display: true)
        } else {
            panel.center()
        }
        
        panel.isMovableByWindowBackground = true
        
        let controller = NSWindowController(window: panel)
        controller.showWindow(nil)
        
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.windowController = controller
    }
    
    func close() {
        windowController?.close()
        windowController = nil
    }
}

struct FloatingToolContainer: View {
    let tool: ToolType
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label(tool.name, systemImage: tool.icon)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    FloatingToolManager.shared.close()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            Group {
                switch tool {
                case .jsonFormatter: JSONToolView()
                case .base64: Base64ToolView()
                case .jwt: JWTToolView()
                case .unixTime: UnixTimeToolView()
                case .url: URLToolView()
                case .hash: HashToolView()
                case .mermaid: MermaidToolView()
                }
            }
        }
    }
}
