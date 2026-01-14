import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var activeTools: [ToolType] = []
    @Published var disabledTools: [ToolType] = []
    
    private let storageKey = "SidebarToolsConfiguration"
    
    init() {
        loadConfiguration()
    }
    
    func loadConfiguration() {
        let allTools = ToolType.allCases
        
        guard let data = UserDefaults.standard.array(forKey: storageKey) as? [String] else {
            // First run: All tools enabled in default order
            self.activeTools = allTools
            self.disabledTools = []
            return
        }
        
        // Convert strings back to ToolType
        let savedTools = data.compactMap { ToolType(rawValue: $0) }
        
        // 1. Identify active tools (intersection of saved and existing)
        // We filter savedTools to ensure we don't crash on removed enum cases
        var validActiveTools = savedTools.filter { allTools.contains($0) }
        
        // 2. Identify missing tools (new features added since last save)
        // These should probably be added to active or disabled? 
        // Let's add them to active by default so users see new features.
        let existingSet = Set(validActiveTools)
        let newTools = allTools.filter { !existingSet.contains($0) }
        
        validActiveTools.append(contentsOf: newTools)
        
        self.activeTools = validActiveTools
        
        // 3. Calculate disabled tools (in this simple version, we assume if it's not in saved, it might be disabled
        // BUT, my logic above adds "missing" tools to active. 
        // To support "Disabled", we actually need to store TWO lists or just rely on the UI to move things between "Active" and "Hidden" sections.
        // For simplicity, let's say: The saved array is the ORDERED ACTIVE list. 
        // Any tool in ToolType.allCases but NOT in saved array is HIDDEN.
        
        // WAIT: If I just use one array for "Active", how do I know if a "missing" tool is "newly added by developer" (should be shown) or "explicitly hidden by user" (should stay hidden)?
        // Use case: User hides "Base64". I release v2.0 with "Hash". "Hash" should appear. "Base64" should stay hidden.
        // Current logic: I appended `newTools` to `activeTools`. 
        // If a user *removed* a tool, it wouldn't be in `savedTools`.
        // So `newTools` would capture it again and re-enable it.
        
        // Better approach: Store "All Known Tools" in order.
        // But to support "Hiding", we need a separate state or a struct.
        // Let's keep it simple for now: Just Reordering and Hiding.
        // We will store a dictionary or a struct? No, keep it simple.
        // Let's store: `enabledTools: [String]` and `disabledTools: [String]`.
        
        if let disabledData = UserDefaults.standard.array(forKey: storageKey + "_Disabled") as? [String] {
             let savedDisabled = disabledData.compactMap { ToolType(rawValue: $0) }
             self.disabledTools = savedDisabled.filter { allTools.contains($0) }
        } else {
             self.disabledTools = []
        }
        
        // Now check for NEW tools (in neither list)
        let activeSet = Set(self.activeTools)
        let disabledSet = Set(self.disabledTools)
        
        let trulyNewTools = allTools.filter { !activeSet.contains($0) && !disabledSet.contains($0) }
        self.activeTools.append(contentsOf: trulyNewTools)
    }
    
    func save() {
        let activeStrings = activeTools.map { $0.rawValue }
        let disabledStrings = disabledTools.map { $0.rawValue }
        
        UserDefaults.standard.set(activeStrings, forKey: storageKey)
        UserDefaults.standard.set(disabledStrings, forKey: storageKey + "_Disabled")
    }
    
    func moveActive(from source: IndexSet, to destination: Int) {
        activeTools.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func toggleTool(_ tool: ToolType) {
        if let index = activeTools.firstIndex(of: tool) {
            activeTools.remove(at: index)
            disabledTools.append(tool)
        } else if let index = disabledTools.firstIndex(of: tool) {
            disabledTools.remove(at: index)
            activeTools.append(tool)
        }
        save()
    }
}
