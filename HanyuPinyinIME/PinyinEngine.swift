import Foundation

enum PinyinVowel: String {
    case a, e, i, o, u, v // Using 'v' for 'ü'
}

let pinyinToneMapLower: [PinyinVowel: [Character]] = [
    .a: ["ā", "á", "ǎ", "à", "a"],
    .e: ["ē", "é", "ě", "è", "e"],
    .i: ["ī", "í", "ǐ", "ì", "i"],
    .o: ["ō", "ó", "ǒ", "ò", "o"],
    .u: ["ū", "ú", "ǔ", "ù", "u"],
    .v: ["ǖ", "ǘ", "ǚ", "ǜ", "ü"]
]

let pinyinToneMapUpper: [PinyinVowel: [Character]] = [
    .a: ["Ā", "Á", "Ǎ", "À", "A"],
    .e: ["Ē", "É", "Ě", "È", "E"],
    .i: ["Ī", "Í", "Ǐ", "Ì", "I"],
    .o: ["Ō", "Ó", "Ǒ", "Ò", "O"],
    .u: ["Ū", "Ú", "Ǔ", "Ù", "U"],
    .v: ["Ǖ", "Ǘ", "Ǚ", "Ǜ", "Ü"]
]

class PinyinEngine {
    private func isUppercaseLetter(_ c: Character) -> Bool {
        let s = String(c)
        return s.uppercased() == s && s.lowercased() != s
    }

    private func normalizeUmlautPreservingCase(_ input: String) -> String {
        // Replace v/V with ü/Ü by default; after j/q/x/y or J/Q/X/Y replace with u/U
        guard !input.isEmpty else { return input }
        let first = input.first!

        let startsWithJQXY = "jqxyJQXY".contains(first)
        var out = ""
        out.reserveCapacity(input.count)
        for ch in input {
            if ch == "v" || ch == "V" {
                if startsWithJQXY {
                    out.append(isUppercaseLetter(ch) ? "U" : "u")
                } else {
                    out.append(isUppercaseLetter(ch) ? "Ü" : "ü")
                }
            } else {
                out.append(ch)
            }
        }
        return out
    }

    func convert(syllable: String, tone: Int) -> String {
        // Step 1: Normalize ü/u representation with case preserved
        let normalized = normalizeUmlautPreservingCase(syllable)

        // If tone invalid, return normalized unchanged
        guard (1...5).contains(tone) else {
            return normalized
        }

        // Step 2: Use lowercase copy for rule logic without losing ü
        let logic = normalized.lowercased()

        // Step 3: Find target vowel index & type per rules
        var targetIndex: Int? = nil
        var targetVowel: PinyinVowel? = nil

        if let r = logic.range(of: "a") {
            targetIndex = logic.distance(from: logic.startIndex, to: r.lowerBound)
            targetVowel = .a
        } else if let r = logic.range(of: "e") {
            targetIndex = logic.distance(from: logic.startIndex, to: r.lowerBound)
            targetVowel = .e
        } else if let r = logic.range(of: "ou") {
            targetIndex = logic.distance(from: logic.startIndex, to: r.lowerBound)
            targetVowel = .o
        } else {
            var idx = logic.count - 1
            for ch in logic.reversed() {
                let s = String(ch)
                if let p = PinyinVowel(rawValue: s) {
                    targetIndex = idx
                    targetVowel = p
                    break
                } else if s == "ü" {
                    targetIndex = idx
                    targetVowel = .v
                    break
                }
                idx -= 1
            }
        }

        guard let tIndex = targetIndex, let tVowel = targetVowel else {
            return normalized
        }

        // Step 4: Build result with tone mark and original casing
        let origChars = Array(normalized)
        var outChars = origChars

        // Determine if target should be uppercase based on original char case at that index
        let targetOrigChar = origChars[tIndex]
        let useUpper = isUppercaseLetter(targetOrigChar)
        let toneMap = useUpper ? pinyinToneMapUpper : pinyinToneMapLower
        guard let toned = toneMap[tVowel]?[tone - 1] else { return normalized }
        outChars[tIndex] = toned

        // Ensure non-target letters keep their original case; also ensure logic-driven changes (e.g., Ü) preserved
        // We already preserved case in normalization, so we only need to ensure all other letters maintain their case.
        // No additional work required here.

        return String(outChars)
    }
}
