import Foundation
import Combine
import AppKit

class JSONToolViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""
    @Published var errorMessage: String? = nil
    @Published var indentation: JSONService.Indentation = .twoSpaces
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $input
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.processJSON(text)
            }
            .store(in: &cancellables)
            
        $indentation
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.processJSON(self.input)
            }
            .store(in: &cancellables)
    }
    
    private func processJSON(_ text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.output = ""
            self.errorMessage = nil
            return
        }
        
        let result = JSONService.format(text, indentation: indentation)
        
        switch result {
        case .success(let formatted):
            self.output = formatted
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
    
    func unescapeInput() {
        if input.isEmpty { return }
        self.input = JSONService.removeEscapeCharacters(input)
    }
}
