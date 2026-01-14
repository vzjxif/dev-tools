import Foundation

struct UnixTimeService {
    
    struct DateFormatItem: Identifiable {
        let id = UUID()
        let label: String
        let value: String
        let helpText: String?
    }
    
    static func getFormats(from timestamp: Double) -> [DateFormatItem] {
        let date = Date(timeIntervalSince1970: timestamp)
        var items: [DateFormatItem] = []
        
        let isoUTC = ISO8601DateFormatter()
        isoUTC.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        items.append(DateFormatItem(label: "ISO 8601 (UTC)", value: isoUTC.string(from: date), helpText: "Standard ISO format in UTC"))
        
        let isoLocal = ISO8601DateFormatter()
        isoLocal.timeZone = TimeZone.current
        isoLocal.formatOptions = [.withInternetDateTime, .withTimeZone]
        items.append(DateFormatItem(label: "ISO 8601 (Local)", value: isoLocal.string(from: date), helpText: "ISO format in your local timezone"))
        
        let rfc = DateFormatter()
        rfc.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        items.append(DateFormatItem(label: "RFC 2822", value: rfc.string(from: date), helpText: "Common in HTTP headers and Email"))
        
        let readableUTC = DateFormatter()
        readableUTC.timeZone = TimeZone(identifier: "UTC")
        readableUTC.dateStyle = .full
        readableUTC.timeStyle = .medium
        items.append(DateFormatItem(label: "UTC (Full)", value: readableUTC.string(from: date), helpText: nil))
        
        let readableLocal = DateFormatter()
        readableLocal.timeZone = TimeZone.current
        readableLocal.dateStyle = .full
        readableLocal.timeStyle = .medium
        items.append(DateFormatItem(label: "Local (Full)", value: readableLocal.string(from: date), helpText: nil))
        
        let short = DateFormatter()
        short.dateStyle = .short
        short.timeStyle = .medium
        items.append(DateFormatItem(label: "Short", value: short.string(from: date), helpText: nil))
        
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .full
        items.append(DateFormatItem(label: "Relative", value: relative.localizedString(for: date, relativeTo: Date()), helpText: nil))
        
        return items
    }

    static func timestampToString(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func stringToTimestamp(_ dateString: String) -> Double? {
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        simpleFormatter.timeZone = TimeZone.current
        if let date = simpleFormatter.date(from: dateString) {
            return date.timeIntervalSince1970
        }
        
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFractional.date(from: dateString) {
            return date.timeIntervalSince1970
        }
        
        let isoStandard = ISO8601DateFormatter()
        if let date = isoStandard.date(from: dateString) {
            return date.timeIntervalSince1970
        }
        
        return nil
    }
    
    static func currentTimestamp() -> Double {
        return Date().timeIntervalSince1970
    }
}
