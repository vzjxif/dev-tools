import Foundation

struct JWTService {
    struct DecodedToken {
        let header: String
        let payload: String
        let signature: String
    }
    
    static func decode(_ token: String) -> Result<DecodedToken, Error> {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            return .failure(NSError(domain: "JWTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JWT format. Expected 3 parts separated by dots."]))
        }
        
        let header = decodeBase64Url(parts[0])
        let payload = decodeBase64Url(parts[1])
        let signature = parts[2]
        
        // Try to pretty print JSON if possible
        let formattedHeader = formatJSON(header)
        let formattedPayload = formatJSON(payload)
        
        return .success(DecodedToken(header: formattedHeader, payload: formattedPayload, signature: signature))
    }
    
    private static func decodeBase64Url(_ input: String) -> String {
        var base64 = input
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = String(repeating: "=", count: Int(paddingLength))
            base64 += padding
        }
        
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
              let string = String(data: data, encoding: .utf8) else {
            return input // Return original if decode fails
        }
        
        return string
    }
    
    private static func formatJSON(_ json: String) -> String {
        guard let data = json.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return json
        }
        return prettyString
    }
}
