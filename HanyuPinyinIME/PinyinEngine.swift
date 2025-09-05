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
    func convert(syllable: String, tone: Int) -> String {
        guard (1...5).contains(tone) else {
            return syllable
        }

        // Find the vowel to place the tone mark on, according to pinyin rules:
        // 1. 'a' or 'e' always gets the tone.
        // 2. In 'ou', 'o' gets the tone.
        // 3. Otherwise, the last vowel gets the tone.
        var targetVowel: (vowel: PinyinVowel, index: String.Index)?

        if let range = syllable.range(of: "a") {
            targetVowel = (.a, range.lowerBound)
        } else if let range = syllable.range(of: "e") {
            targetVowel = (.e, range.lowerBound)
        } else if let range = syllable.range(of: "ou") {
            targetVowel = (.o, range.lowerBound)
        } else {
            // Find the last vowel in the syllable
            let vowels: [PinyinVowel] = [.a, .e, .i, .o, .u, .v]
            for (index, char) in syllable.enumerated().reversed() {
                if let pinyinVowel = PinyinVowel(rawValue: String(char)), vowels.contains(pinyinVowel) {
                    targetVowel = (pinyinVowel, syllable.index(syllable.startIndex, offsetBy: index))
                    break
                }
            }
        }

        guard let target = targetVowel,
              let tonedVowelChar = pinyinToneMap[target.vowel]?[tone - 1] else {
            return syllable
        }

        var result = syllable
        result.remove(at: target.index)
        result.insert(tonedVowelChar, at: target.index)

        return result
    }
}

