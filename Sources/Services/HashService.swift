import Foundation
import CryptoKit

struct HashService {
    struct HashResult {
        let algorithm: String
        let hex: String
        let base64: String
    }
    
    static func process(_ input: String) -> [HashResult] {
        guard let data = input.data(using: .utf8) else { return [] }
        
        var results: [HashResult] = []
        
        // MD5 (Insecure but commonly used for checksums)
        let md5 = Insecure.MD5.hash(data: data)
        results.append(HashResult(
            algorithm: "MD5",
            hex: md5.map { String(format: "%02x", $0) }.joined(),
            base64: Data(md5).base64EncodedString()
        ))
        
        // SHA-1 (Insecure)
        let sha1 = Insecure.SHA1.hash(data: data)
        results.append(HashResult(
            algorithm: "SHA-1",
            hex: sha1.map { String(format: "%02x", $0) }.joined(),
            base64: Data(sha1).base64EncodedString()
        ))
        
        // SHA-256
        let sha256 = SHA256.hash(data: data)
        results.append(HashResult(
            algorithm: "SHA-256",
            hex: sha256.map { String(format: "%02x", $0) }.joined(),
            base64: Data(sha256).base64EncodedString()
        ))
        
        // SHA-512
        let sha512 = SHA512.hash(data: data)
        results.append(HashResult(
            algorithm: "SHA-512",
            hex: sha512.map { String(format: "%02x", $0) }.joined(),
            base64: Data(sha512).base64EncodedString()
        ))
        
        return results
    }
}
