import XCTest
@testable import HanyuPinyinIME

final class PinyinEngineSpecTests: XCTestCase {
    var engine: PinyinEngine!

    override func setUp() {
        super.setUp()
        engine = PinyinEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    struct Case {
        let syllable: String
        let tone: Int
        let expected: String
        let note: String
    }

    func testTonePlacement_BasicVowels() {
        // GB/T 16159 & ISO 7098: a/e have priority; otherwise last vowel
        let cases: [Case] = [
            .init(syllable: "a", tone: 1, expected: "ā", note: "single vowel a"),
            .init(syllable: "e", tone: 2, expected: "é", note: "single vowel e"),
            .init(syllable: "i", tone: 3, expected: "ǐ", note: "single vowel i"),
            .init(syllable: "o", tone: 4, expected: "ò", note: "single vowel o"),
            .init(syllable: "u", tone: 1, expected: "ū", note: "single vowel u"),
            .init(syllable: "ba", tone: 1, expected: "bā", note: "a gets tone"),
            .init(syllable: "me", tone: 2, expected: "mé", note: "e gets tone"),
            .init(syllable: "li", tone: 3, expected: "lǐ", note: "last vowel i"),
            .init(syllable: "bo", tone: 4, expected: "bò", note: "last vowel o"),
            .init(syllable: "lu", tone: 2, expected: "lú", note: "last vowel u"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testTonePlacement_DiphthongsAndFinals() {
        // ISO 7098: In "ou" the tone mark goes on o; otherwise a/e priority, else last vowel
        let cases: [Case] = [
            .init(syllable: "ai", tone: 2, expected: "ái", note: "last vowel i"),
            .init(syllable: "ei", tone: 3, expected: "ěi", note: "e priority"),
            .init(syllable: "ao", tone: 4, expected: "ào", note: "a priority"),
            .init(syllable: "ou", tone: 3, expected: "ǒu", note: "ou -> o gets tone"),
            .init(syllable: "an", tone: 2, expected: "án", note: "a priority"),
            .init(syllable: "en", tone: 3, expected: "ěn", note: "e priority"),
            .init(syllable: "ang", tone: 4, expected: "àng", note: "a priority"),
            .init(syllable: "eng", tone: 2, expected: "éng", note: "e priority"),
            .init(syllable: "ong", tone: 3, expected: "ǒng", note: "o marked"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testTonePlacement_CompoundInitials() {
        let cases: [Case] = [
            .init(syllable: "shi", tone: 4, expected: "shì", note: "apical vowel i"),
            .init(syllable: "zhi", tone: 1, expected: "zhī", note: "apical vowel i"),
            .init(syllable: "chi", tone: 2, expected: "chí", note: "apical vowel i"),
            .init(syllable: "ri", tone: 3, expected: "rǐ", note: "apical vowel i"),
            .init(syllable: "zi", tone: 1, expected: "zī", note: "apical vowel i"),
            .init(syllable: "ci", tone: 2, expected: "cí", note: "apical vowel i"),
            .init(syllable: "si", tone: 3, expected: "sǐ", note: "apical vowel i"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testTonePlacement_IU_UI_Rules() {
        // For iu/ui the last vowel is marked (liù, guī)
        let cases: [Case] = [
            .init(syllable: "liu", tone: 4, expected: "liù", note: "iu -> u gets tone"),
            .init(syllable: "niu", tone: 3, expected: "niǔ", note: "iu -> u gets tone"),
            .init(syllable: "gui", tone: 1, expected: "guī", note: "ui -> i gets tone"),
            .init(syllable: "shui", tone: 2, expected: "shuí", note: "ui -> i gets tone"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testTonePlacement_WithMedials_I_Y_U() {
        let cases: [Case] = [
            .init(syllable: "xia", tone: 2, expected: "xiá", note: "a priority"),
            .init(syllable: "xie", tone: 4, expected: "xiè", note: "e priority"),
            .init(syllable: "biao", tone: 1, expected: "biāo", note: "a priority"),
            .init(syllable: "lian", tone: 3, expected: "liǎn", note: "a priority"),
            .init(syllable: "liang", tone: 4, expected: "liàng", note: "a priority"),
            .init(syllable: "lin", tone: 2, expected: "lín", note: "i marked"),
            .init(syllable: "ting", tone: 3, expected: "tǐng", note: "i marked"),
            .init(syllable: "xiong", tone: 2, expected: "xióng", note: "iong -> o marked"),
            .init(syllable: "hua", tone: 2, expected: "huá", note: "a priority"),
            .init(syllable: "tuo", tone: 4, expected: "tuò", note: "o marked"),
            .init(syllable: "guai", tone: 2, expected: "guái", note: "last vowel i"),
            .init(syllable: "duan", tone: 3, expected: "duǎn", note: "a priority"),
            .init(syllable: "zhuang", tone: 4, expected: "zhuàng", note: "a priority"),
            .init(syllable: "lun", tone: 2, expected: "lún", note: "u marked"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testUmlaut_U_After_JQXY_IsWrittenWithoutDiaeresis() {
        // GB/T 16159 & ISO 7098: ü is written as u after j/q/x/y (e.g., ju, jue, juan, yun),
        // with the tone mark on u but without the diaeresis. This is a spec expectation.
        // These tests will drive the engine to implement the orthography exception.
        let cases: [Case] = [
            .init(syllable: "jv", tone: 1, expected: "jū", note: "jü -> ju (no diaeresis)"),
            .init(syllable: "jve", tone: 4, expected: "juè", note: "jüe -> jue (no diaeresis)"),
            .init(syllable: "jvan", tone: 2, expected: "juán", note: "jüan -> juan (no diaeresis)"),
            .init(syllable: "qv", tone: 3, expected: "qǔ", note: "qü -> qu (no diaeresis)"),
            .init(syllable: "xve", tone: 2, expected: "xué", note: "xüe -> xue (no diaeresis)"),
            .init(syllable: "yv", tone: 2, expected: "yú", note: "yü -> yu (no diaeresis)"),
            .init(syllable: "yve", tone: 1, expected: "yuē", note: "yüe -> yue (no diaeresis)"),
            .init(syllable: "yvan", tone: 3, expected: "yuǎn", note: "yüan -> yuan (no diaeresis)"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testUmlaut_U_RetainedFor_N_L() {
        // GB/T 16159 & ISO 7098: ü must be retained for nü/lü and nüe/lüe to distinguish from nu/lu
        let cases: [Case] = [
            .init(syllable: "nv", tone: 3, expected: "nǚ", note: "nü retains diaeresis"),
            .init(syllable: "lv", tone: 4, expected: "lǜ", note: "lü retains diaeresis"),
            .init(syllable: "nve", tone: 2, expected: "nüé", note: "nüe retains diaeresis; tone on e"),
            .init(syllable: "lve", tone: 4, expected: "lüè", note: "lüe retains diaeresis; tone on e"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testNeutralTone_5HasNoDiacritic() {
        // Neutral tone (5) has no diacritic; syllable spelled base form
        let cases: [Case] = [
            .init(syllable: "ma", tone: 5, expected: "ma", note: "neutral tone no mark"),
            .init(syllable: "de", tone: 5, expected: "de", note: "neutral tone no mark"),
            .init(syllable: "men", tone: 5, expected: "men", note: "neutral tone no mark"),
            .init(syllable: "ou", tone: 5, expected: "ou", note: "neutral tone no mark"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testInvalidTone_ReturnsUnchanged() {
        // Out-of-range tone should return syllable unchanged
        XCTAssertEqual(engine.convert(syllable: "ma", tone: 0), "ma")
        XCTAssertEqual(engine.convert(syllable: "ma", tone: 6), "ma")
        XCTAssertEqual(engine.convert(syllable: "", tone: 3), "")
        XCTAssertEqual(engine.convert(syllable: "sh", tone: 2), "sh") // no vowel
    }
}

