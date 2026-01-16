import Foundation
import Carbon
import Cocoa
import Combine

class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()
    
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var callbacks: [UInt32: () -> Void] = [:]
    private var currentId: UInt32 = 1
    
    init() {
        installEventHandler()
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        InstallEventHandler(GetApplicationEventTarget(), { (handler, event, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            
            if status == noErr {
                HotkeyManager.shared.handleHotkey(id: hotKeyID.id)
            }
            
            return noErr
        }, 1, &eventType, nil, nil)
    }
    
    func handleHotkey(id: UInt32) {
        DispatchQueue.main.async {
            self.callbacks[id]?()
        }
    }
    
    func register(shortcut: KeyboardShortcut, action: @escaping () -> Void) {
        let id = currentId
        currentId += 1
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(1752460081) 
        hotKeyID.id = id
        
        var hotKeyRef: EventHotKeyRef?
        
        var carbonModifiers: UInt32 = 0
        let flags = NSEvent.ModifierFlags(rawValue: UInt(shortcut.modifiers))
        
        if flags.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if flags.contains(.option)  { carbonModifiers |= UInt32(optionKey) }
        if flags.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if flags.contains(.shift)   { carbonModifiers |= UInt32(shiftKey) }
        
        let status = RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let ref = hotKeyRef {
            hotKeyRefs[id] = ref
            callbacks[id] = action
            print("Registered hotkey ID \(id) for \(shortcut.description)")
        } else {
            print("Failed to register hotkey: \(status)")
        }
    }
    
    func unregisterAll() {
        for (_, ref) in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()
        callbacks.removeAll()
    }
}
