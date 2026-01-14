import Foundation

struct Base64Service {
    enum Mode: String, CaseIterable, Identifiable {
        case encode = "Encode"
        case decode = "Decode"
        
        var id: String { rawValue }
    }
    
    static func process(_ input: String, mode: Mode) -> Result<String, Error> {
        guard !input.isEmpty else { return .success("") }
        
        switch mode {
        case .encode:
            guard let data = input.data(using: .utf8) else {
                return .failure(NSError(domain: "Base64Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 string"]))
            }
            return .success(data.base64EncodedString())
            
        case .decode:
            // Base64 decoding can be tricky with whitespaces/newlines, so we clean it up
            let cleanInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = Data(base64Encoded: cleanInput) else {
                return .failure(NSError(domain: "Base64Service", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid Base64 string"]))
            }
            guard let string = String(data: data, encoding: .utf8) else {
                return .failure(NSError(domain: "Base64Service", code: -3, userInfo: [NSLocalizedDescriptionKey: "Decoded data is not valid UTF-8"]))
            }
            return .success(string)
        }
    }
}
