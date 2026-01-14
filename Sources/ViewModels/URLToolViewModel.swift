import Foundation
import Combine
import AppKit

class URLToolViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""
    @Published var mode: URLService.Mode = .encode
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($input, $mode)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] input, mode in
                self?.process(input, mode: mode)
            }
            .store(in: &cancellables)
    }
    
    private func process(_ text: String, mode: URLService.Mode) {
        if text.isEmpty {
            self.output = ""
            return
        }
        self.output = URLService.process(text, mode: mode)
    }
    
    func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            self.input = string
        }
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
    }
    
    func clear() {
        self.input = ""
        self.output = ""
    }
}
