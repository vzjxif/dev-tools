import Foundation
import Combine
import AppKit

class MermaidToolViewModel: ObservableObject {
    @Published var input: String = """
    graph TD
        A[Start] --> B{Is it working?}
        B -->|Yes| C[Great!]
        B -->|No| D[Debug]
        D --> B
    """
    
    @Published var htmlContent: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $input
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.updateHTML(text)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("AutoPasteClipboard"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pasteFromClipboard()
            }
            .store(in: &cancellables)
            
        updateHTML(input)
    }
    
    private func updateHTML(_ text: String) {
        htmlContent = MermaidService.generateHTML(from: text)
    }
    
    func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            self.input = string
        }
    }
    
    func clear() {
        input = "graph TD\n    A[Start] --> B[End]"
    }
}
