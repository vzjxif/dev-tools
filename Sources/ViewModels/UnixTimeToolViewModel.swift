import Foundation
import Combine
import AppKit

class UnixTimeToolViewModel: ObservableObject {
    @Published var timestampInput: String = ""
    @Published var dateInput: String = ""
    @Published var errorMessage: String? = nil
    @Published var otherFormats: [UnixTimeService.DateFormatItem] = []
    
    enum TimeUnit: String, CaseIterable, Identifiable {
        case seconds = "Seconds (s)"
        case milliseconds = "Milliseconds (ms)"
        var id: String { rawValue }
    }
    
    @Published var timeUnit: TimeUnit = .seconds
    
    private var cancellables = Set<AnyCancellable>()
    private var isUpdating = false
    
    init() {
        // Handle Timestamp -> Date
        $timestampInput
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .combineLatest($timeUnit)
            .sink { [weak self] input, unit in
                guard let self = self, !self.isUpdating else { return }
                if input.isEmpty { return }
                
                if let rawVal = Double(input) {
                    let ts = unit == .milliseconds ? rawVal / 1000 : rawVal
                    
                    self.isUpdating = true
                    self.dateInput = UnixTimeService.timestampToString(ts)
                    self.otherFormats = UnixTimeService.getFormats(from: ts)
                    self.errorMessage = nil
                    self.isUpdating = false
                }
            }
            .store(in: &cancellables)
            
        // Handle Date -> Timestamp
        $dateInput
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .combineLatest($timeUnit)
            .sink { [weak self] input, unit in
                guard let self = self, !self.isUpdating else { return }
                if input.isEmpty { return }
                
                if let ts = UnixTimeService.stringToTimestamp(input) {
                    self.isUpdating = true
                    
                    let displayVal = unit == .milliseconds ? ts * 1000 : ts
                    self.timestampInput = String(format: "%.0f", displayVal)
                    self.otherFormats = UnixTimeService.getFormats(from: ts)
                    self.errorMessage = nil
                    self.isUpdating = false
                }
            }
            .store(in: &cancellables)
            
        // Init with current time
        setToNow()
    }
    
    func setToNow() {
        let now = UnixTimeService.currentTimestamp()
        self.isUpdating = true
        let displayVal = timeUnit == .milliseconds ? now * 1000 : now
        self.timestampInput = String(format: "%.0f", displayVal)
        self.dateInput = UnixTimeService.timestampToString(now)
        self.otherFormats = UnixTimeService.getFormats(from: now)
        self.errorMessage = nil
        self.isUpdating = false
    }
    
    func copyTimestamp() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(timestampInput, forType: .string)
    }
    
    func copyDate() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(dateInput, forType: .string)
    }
}
