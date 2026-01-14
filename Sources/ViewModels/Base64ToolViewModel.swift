import Foundation
import Combine
import AppKit

class Base64ToolViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""
    @Published var mode: Base64Service.Mode = .encode
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($input, $mode)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] input, mode in
                self?.process(input, mode: mode)
            }
            .store(in: &cancellables)
    }
    
    private func process(_ text: String, mode: Base64Service.Mode) {
        if text.isEmpty {
            self.output = ""
            self.errorMessage = nil
            return
        }
        
        let result = Base64Service.process(text, mode: mode)
        
        switch result {
        case .success(let resultString):
            self.output = resultString
            self.errorMessage = nil
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
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
        self.errorMessage = nil
    }
}
