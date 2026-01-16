import SwiftUI

struct ShortcutRecorder: NSViewRepresentable {
    @Binding var shortcut: KeyboardShortcut?
    
    func makeNSView(context: Context) -> RecorderButton {
        let button = RecorderButton()
        button.shortcut = shortcut
        button.onChange = { newShortcut in
            self.shortcut = newShortcut
        }
        return button
    }
    
    func updateNSView(_ view: RecorderButton, context: Context) {
        view.shortcut = shortcut
    }
    
    class RecorderButton: NSButton {
        var shortcut: KeyboardShortcut? {
            didSet {
                updateTitle()
            }
        }
        var onChange: ((KeyboardShortcut?) -> Void)?
        
        private var preventFocusLoop = false
        
        private var isRecording = false {
            didSet {
                guard isRecording != oldValue else { return }
                updateTitle()
                
                if !preventFocusLoop {
                    if isRecording {
                        window?.makeFirstResponder(self)
                    } else {
                        if window?.firstResponder === self {
                            window?.makeFirstResponder(nil)
                        }
                    }
                }
            }
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.bezelStyle = .rounded
            self.target = self
            self.action = #selector(clicked)
            updateTitle()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func clicked() {
            isRecording.toggle()
        }
        
        func updateTitle() {
            if isRecording {
                self.title = "Press Keys..."
                self.state = .on
            } else if let s = shortcut {
                self.title = s.description
                self.state = .off
            } else {
                self.title = "Record Shortcut"
                self.state = .off
            }
        }
        
        override func keyDown(with event: NSEvent) {
            guard isRecording else {
                super.keyDown(with: event)
                return
            }
            
            if event.keyCode == 53 {
                isRecording = false
                return
            }
            
            if event.keyCode == 51 {
                shortcut = nil
                onChange?(nil)
                isRecording = false
                return
            }
            
            let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
            
            let newShortcut = KeyboardShortcut(
                keyCode: Int(event.keyCode),
                modifiers: Int(modifiers.rawValue)
            )
            
            shortcut = newShortcut
            onChange?(newShortcut)
            isRecording = false
        }
        
        override func resignFirstResponder() -> Bool {
            if isRecording {
                preventFocusLoop = true
                isRecording = false
                preventFocusLoop = false
            }
            return super.resignFirstResponder()
        }
    }
}
