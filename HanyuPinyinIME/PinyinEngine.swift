import Foundation

enum PinyinVowel: String {
    case a, e, i, o, u, v // Using 'v' for 'ü'
}

let pinyinToneMap: [PinyinVowel: [Character]] = [
    .a: ["ā", "á", "ǎ", "à", "a"],
    .e: ["ē", "é", "ě", "è", "e"],
    .i: ["ī", "í", "ǐ", "ì", "i"],
    .o: ["ō", "ó", "ǒ", "ò", "o"],
    .u: ["ū", "ú", "ǔ", "ù", "u"],
    .v: ["ǖ", "ǘ", "ǚ", "ǜ", "ü"]
]

class PinyinEngine {
    private func normalizeUmlaut(_ input: String) -> String {
        guard input.contains("v") else { return input }
        guard let first = input.first else { return input }
        // GB/T 16159 & ISO 7098: After j/q/x/y, write ü as plain u; otherwise keep ü
        if "jqxy".contains(first) {
            return input.replacingOccurrences(of: "v", with: "u")
        } else {
            return input.replacingOccurrences(of: "v", with: "ü")
        }
    }

    func convert(syllable: String, tone: Int) -> String {
        // Normalize ü/u representation before tone placement
        let base = normalizeUmlaut(syllable)

        guard (1...5).contains(tone) else {
            return base
        }

        // Find the vowel to place the tone mark on, according to pinyin rules:
        // 1. 'a' or 'e' always gets the tone.
        // 2. In 'ou', 'o' gets the tone.
        // 3. Otherwise, the last vowel gets the tone.
        var targetVowel: (vowel: PinyinVowel, index: String.Index)?

        if let range = base.range(of: "a") {
            targetVowel = (.a, range.lowerBound)
        } else if let range = base.range(of: "e") {
            targetVowel = (.e, range.lowerBound)
        } else if let range = base.range(of: "ou") {
            targetVowel = (.o, range.lowerBound)
        } else {
            // Find the last vowel in the syllable
            for (offset, ch) in base.enumerated().reversed() {
                let s = String(ch)
                if let p = PinyinVowel(rawValue: s) {
                    targetVowel = (p, base.index(base.startIndex, offsetBy: offset))
                    break
                } else if s == "ü" {
                    targetVowel = (.v, base.index(base.startIndex, offsetBy: offset))
                    break
                }
            }
        }

        guard let target = targetVowel,
              let tonedVowelChar = pinyinToneMap[target.vowel]?[tone - 1] else {
            return base
        }

        var result = base
        result.remove(at: target.index)
        result.insert(tonedVowelChar, at: target.index)
        return result
    }
}
