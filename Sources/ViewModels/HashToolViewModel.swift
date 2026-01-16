import Foundation
import Combine
import AppKit

class HashToolViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var results: [HashService.HashResult] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $input
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.calculateHashes(text)
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: NSNotification.Name("AutoPasteClipboard"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pasteFromClipboard()
            }
            .store(in: &cancellables)
    }
    
    private func calculateHashes(_ text: String) {
        if text.isEmpty {
            results = []
        } else {
            results = HashService.process(text)
        }
    }
    
    func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            self.input = string
        }
    }
    
    func clear() {
        input = ""
    }
}
