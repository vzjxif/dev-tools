import Foundation
import SwiftUI

enum ToolType: String, CaseIterable, Identifiable {
    case jsonFormatter
    case base64
    case jwt
    case unixTime
    case url
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .jsonFormatter: return "JSON Format/Validate"
        case .base64: return "Base64 String Encode/Decode"
        case .jwt: return "JWT Debugger"
        case .unixTime: return "Unix Time Converter"
        case .url: return "URL Encode/Decode"
        }
    }
    
    var icon: String {
        switch self {
        case .jsonFormatter: return "curlybraces"
        case .base64: return "number"
        case .jwt: return "key.fill"
        case .unixTime: return "clock"
        case .url: return "link"
        }
    }
}
