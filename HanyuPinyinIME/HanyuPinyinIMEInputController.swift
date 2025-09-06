import Cocoa
import InputMethodKit

@objc(HanyuPinyinIMEInputController)
class HanyuPinyinIMEInputController: IMKInputController {
    private let pinyinEngine = PinyinEngine()
    private var preeditBuffer = ""

    override open func deactivateServer(_ sender: Any!) {
        commitComposition(sender)
        super.deactivateServer(sender)
    }
    
    override open func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard event.type == .keyDown else {
            // Commit composition on mouse clicks
            if event.type == .leftMouseDown || event.type == .rightMouseDown {
                commitComposition(sender)
            }
            return false
        }
        
        return handleKeyDown(event, client: sender!)
    }
    
    private func handleKeyDown(_ event: NSEvent, client: Any) -> Bool {
        // Ignore key events with modifiers
        if event.modifierFlags.contains(.command) || event.modifierFlags.contains(.option) || event.modifierFlags.contains(.control) {
            return false
        }
        
        // Handle special keys
        switch event.keyCode {
        case 0x24, 0x30: // Enter or Tab
            commitComposition(client)
            return false // Let the client handle the event
        case 0x33: // Backspace
            if !preeditBuffer.isEmpty {
                preeditBuffer.removeLast()
                updateMarkedText(for: client)
                return true
            }
            return false
        default:
            break
        }
        
        guard let characters = event.characters else {
            return false
        }
        
        for character in characters {
            processCharacter(character, client: client)
        }
        
        return true
    }
    
    private func processCharacter(_ character: Character, client: Any) {
        if let tone = Int(String(character)), (1...5).contains(tone) {
            // Convert the buffer to a toned syllable and commit it
            let convertedSyllable = pinyinEngine.convert(syllable: preeditBuffer, tone: tone)
            commitText(convertedSyllable, client: client)
            preeditBuffer = ""
            updateMarkedText(for: client)
        } else if character.isLetter || character.isNumber {
            // Append allowed characters to the buffer
            preeditBuffer.append(character)
            updateMarkedText(for: client)
        }
    }
    
    private func updateMarkedText(for client: Any) {
        guard let client = client as? IMKTextInput else { return }
        let selectionRange = NSRange(location: preeditBuffer.utf16.count, length: 0)
        client.setMarkedText(preeditBuffer, selectionRange: selectionRange, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
    }
    
    private func commitText(_ text: String, client: Any) {
        guard let client = client as? IMKTextInput, !text.isEmpty else { return }
        client.insertText(text, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
    }
    
    override open func commitComposition(_ sender: Any!) {
        commitText(preeditBuffer, client: sender!)
        preeditBuffer = ""
        updateMarkedText(for: sender!)
    }
    
    override open func recognizedEvents(_ sender: Any!) -> Int {
        let eventMask: NSEvent.EventTypeMask = [.keyDown, .leftMouseDown, .rightMouseDown]
        return Int(eventMask.rawValue)
    }
}
