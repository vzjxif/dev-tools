import Foundation
import Combine
import AppKit

class JWTToolViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var header: String = ""
    @Published var payload: String = ""
    @Published var signature: String = ""
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $input
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] token in
                self?.process(token)
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: NSNotification.Name("AutoPasteClipboard"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pasteFromClipboard()
            }
            .store(in: &cancellables)
    }
    
    private func process(_ token: String) {
        if token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            clearOutput()
            return
        }
        
        var cleanToken = token
        if token.hasPrefix("Bearer ") {
            cleanToken = String(token.dropFirst(7))
        }
        
        let result = JWTService.decode(cleanToken)
        
        switch result {
        case .success(let decoded):
            self.header = decoded.header
            self.payload = decoded.payload
            self.signature = decoded.signature
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
    
    func clear() {
        self.input = ""
        clearOutput()
    }
    
    private func clearOutput() {
        self.header = ""
        self.payload = ""
        self.signature = ""
        self.errorMessage = nil
    }
}
