import Foundation

struct JSONService {
    enum Indentation: Int, CaseIterable, Identifiable {
        case twoSpaces = 2
        case fourSpaces = 4
        
        var id: Int { rawValue }
        var description: String {
            switch self {
            case .twoSpaces: return "2 Spaces"
            case .fourSpaces: return "4 Spaces"
            }
        }
    }
    
    static func removeEscapeCharacters(_ input: String) -> String {
        return input.replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\", with: "\\")
            .replacingOccurrences(of: "\\/", with: "/")
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\t", with: "\t")
            .replacingOccurrences(of: "\\r", with: "\r")
            .replacingOccurrences(of: "\\b", with: "")
            .replacingOccurrences(of: "\\f", with: "")
    }

    static func format(_ input: String, indentation: Indentation) -> Result<String, Error> {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .success("")
        }
        
        guard let data = input.data(using: .utf8) else {
            return .failure(NSError(domain: "JSONService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid encoding"]))
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            var options: JSONSerialization.WritingOptions = [.prettyPrinted]
            if #available(macOS 10.15, *) {
                options.insert(.sortedKeys)
            }
            
            let formattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
            guard let string = String(data: formattedData, encoding: .utf8) else {
                 return .failure(NSError(domain: "JSONService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Conversion failed"]))
            }
            
            return .success(string)
        } catch {
            return .failure(error)
        }
    }
}
