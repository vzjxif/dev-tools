import Foundation

struct URLService {
    enum Mode: String, CaseIterable, Identifiable {
        case encode = "Encode"
        case decode = "Decode"
        
        var id: String { rawValue }
    }
    
    static func process(_ input: String, mode: Mode) -> String {
        switch mode {
        case .encode:
            return input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
        case .decode:
            return input.removingPercentEncoding ?? input
        }
    }
}
