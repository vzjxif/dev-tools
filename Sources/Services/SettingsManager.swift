import Foundation
import Combine
import Cocoa

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var activeTools: [ToolType] = []
    @Published var disabledTools: [ToolType] = []
    @Published var shortcuts: [String: KeyboardShortcut] = [:]
    
    @Published var mainWindowShortcut: KeyboardShortcut?
    @Published var autoPasteEnabled: Bool = true
    
    var openMainWindowAction: (() -> Void)?
    
    private let storageKey = "SidebarToolsConfiguration"
    private let shortcutsKey = "ToolShortcuts"
    private let globalShortcutKey = "GlobalMainWindowShortcut"
    private let autoPasteKey = "AutoPasteEnabled"
    
    init() {
        loadConfiguration()
        loadShortcuts()
    }
    
    func loadConfiguration() {
        let allTools = ToolType.allCases
        
        guard let data = UserDefaults.standard.array(forKey: storageKey) as? [String] else {
            self.activeTools = allTools
            self.disabledTools = []
            if UserDefaults.standard.object(forKey: autoPasteKey) == nil {
                self.autoPasteEnabled = true
            }
            return
        }
        
        if UserDefaults.standard.object(forKey: autoPasteKey) != nil {
            self.autoPasteEnabled = UserDefaults.standard.bool(forKey: autoPasteKey)
        } else {
            self.autoPasteEnabled = true
        }
        
        let savedTools = data.compactMap { ToolType(rawValue: $0) }
        var validActiveTools = savedTools.filter { allTools.contains($0) }
        
        if let disabledData = UserDefaults.standard.array(forKey: storageKey + "_Disabled") as? [String] {
             let savedDisabled = disabledData.compactMap { ToolType(rawValue: $0) }
             self.disabledTools = savedDisabled.filter { allTools.contains($0) }
        } else {
             self.disabledTools = []
        }
        
        let activeSet = Set(validActiveTools)
        let disabledSet = Set(self.disabledTools)
        
        let trulyNewTools = allTools.filter { !activeSet.contains($0) && !disabledSet.contains($0) }
        validActiveTools.append(contentsOf: trulyNewTools)
        
        self.activeTools = validActiveTools
    }
    
    func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: shortcutsKey),
           let decoded = try? JSONDecoder().decode([String: KeyboardShortcut].self, from: data) {
            self.shortcuts = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: globalShortcutKey),
           let decoded = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) {
            self.mainWindowShortcut = decoded
        }
        
        DispatchQueue.main.async {
            self.registerHotkeys()
        }
    }
    
    func save() {
        let activeStrings = activeTools.map { $0.rawValue }
        let disabledStrings = disabledTools.map { $0.rawValue }
        
        UserDefaults.standard.set(activeStrings, forKey: storageKey)
        UserDefaults.standard.set(disabledStrings, forKey: storageKey + "_Disabled")
        UserDefaults.standard.set(autoPasteEnabled, forKey: autoPasteKey)
    }
    
    func saveShortcuts() {
        if let data = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(data, forKey: shortcutsKey)
        }
        
        if let mainSC = mainWindowShortcut, let data = try? JSONEncoder().encode(mainSC) {
            UserDefaults.standard.set(data, forKey: globalShortcutKey)
        } else {
            UserDefaults.standard.removeObject(forKey: globalShortcutKey)
        }
        
        registerHotkeys()
    }
    
    func setShortcut(_ shortcut: KeyboardShortcut?, for tool: ToolType) {
        if let sc = shortcut {
            shortcuts[tool.id] = sc
        } else {
            shortcuts.removeValue(forKey: tool.id)
        }
        saveShortcuts()
    }
    
    func setMainWindowShortcut(_ shortcut: KeyboardShortcut?) {
        self.mainWindowShortcut = shortcut
        saveShortcuts()
    }
    
    func toggleAutoPaste(_ enabled: Bool) {
        self.autoPasteEnabled = enabled
        save()
    }
    
    func registerHotkeys() {
        let manager = HotkeyManager.shared
        manager.unregisterAll()
        
        for (toolId, shortcut) in shortcuts {
            guard let tool = ToolType(rawValue: toolId) else { continue }
            
            manager.register(shortcut: shortcut) { [weak self] in
                DispatchQueue.main.async {
                    let mainWindow = NSApp.windows.first { window in
                        return window.title == "DevTools" && !(window is NSPanel)
                    }
                    
                    if let mainWin = mainWindow {
                        NSApp.activate(ignoringOtherApps: true)
                        mainWin.makeKeyAndOrderFront(nil)
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchTool"), object: tool)
                    } else {
                        FloatingToolManager.shared.show(tool: tool)
                    }
                    
                    if self?.autoPasteEnabled == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             NotificationCenter.default.post(name: NSNotification.Name("AutoPasteClipboard"), object: nil)
                        }
                    }
                }
            }
        }
        
        if let mainSC = mainWindowShortcut {
            manager.register(shortcut: mainSC) { [weak self] in
                DispatchQueue.main.async {
                    let mainWindow = NSApp.windows.first { window in
                        return window.title == "DevTools" && !(window is NSPanel)
                    }
                    
                    if let mainWin = mainWindow {
                        NSApp.activate(ignoringOtherApps: true)
                        mainWin.makeKeyAndOrderFront(nil)
                    } else {
                        self?.openMainWindowAction?()
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
            }
        }
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
