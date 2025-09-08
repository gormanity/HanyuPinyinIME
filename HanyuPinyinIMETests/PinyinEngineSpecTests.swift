import XCTest
@testable import Hanyu_Pinyin

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

    func testEr_AllTones_AndNeutral() {
        let cases: [Case] = [
            .init(syllable: "er", tone: 1, expected: "ēr", note: "er tone 1"),
            .init(syllable: "er", tone: 2, expected: "ér", note: "er tone 2"),
            .init(syllable: "er", tone: 3, expected: "ěr", note: "er tone 3"),
            .init(syllable: "er", tone: 4, expected: "èr", note: "er tone 4"),
            .init(syllable: "er", tone: 5, expected: "er", note: "er neutral tone")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testBasicVowels_AllTones() {
        // Verify tones 1-4 for basic vowels a/e/i/o/u and ü via nv
        let cases: [Case] = [
            .init(syllable: "a", tone: 1, expected: "ā", note: "a1"),
            .init(syllable: "a", tone: 2, expected: "á", note: "a2"),
            .init(syllable: "a", tone: 3, expected: "ǎ", note: "a3"),
            .init(syllable: "a", tone: 4, expected: "à", note: "a4"),

            .init(syllable: "e", tone: 1, expected: "ē", note: "e1"),
            .init(syllable: "e", tone: 2, expected: "é", note: "e2"),
            .init(syllable: "e", tone: 3, expected: "ě", note: "e3"),
            .init(syllable: "e", tone: 4, expected: "è", note: "e4"),

            .init(syllable: "i", tone: 1, expected: "ī", note: "i1"),
            .init(syllable: "i", tone: 2, expected: "í", note: "i2"),
            .init(syllable: "i", tone: 3, expected: "ǐ", note: "i3"),
            .init(syllable: "i", tone: 4, expected: "ì", note: "i4"),

            .init(syllable: "o", tone: 1, expected: "ō", note: "o1"),
            .init(syllable: "o", tone: 2, expected: "ó", note: "o2"),
            .init(syllable: "o", tone: 3, expected: "ǒ", note: "o3"),
            .init(syllable: "o", tone: 4, expected: "ò", note: "o4"),

            .init(syllable: "u", tone: 1, expected: "ū", note: "u1"),
            .init(syllable: "u", tone: 2, expected: "ú", note: "u2"),
            .init(syllable: "u", tone: 3, expected: "ǔ", note: "u3"),
            .init(syllable: "u", tone: 4, expected: "ù", note: "u4"),

            .init(syllable: "nv", tone: 1, expected: "nǖ", note: "ü1 via nv"),
            .init(syllable: "nv", tone: 2, expected: "nǘ", note: "ü2 via nv"),
            .init(syllable: "nv", tone: 3, expected: "nǚ", note: "ü3 via nv"),
            .init(syllable: "nv", tone: 4, expected: "nǜ", note: "ü4 via nv")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testUmlaut_AfterJQXY_MoreCases() {
        // jun/qun/xun/yun; xuan/quan; que — all written without diaeresis but toned correctly
        let cases: [Case] = [
            .init(syllable: "jvn", tone: 2, expected: "jún", note: "jün -> jun"),
            .init(syllable: "qvn", tone: 3, expected: "qǔn", note: "qü n -> qun"),
            .init(syllable: "xvn", tone: 4, expected: "xùn", note: "xün -> xun"),
            .init(syllable: "yvn", tone: 2, expected: "yún", note: "yün -> yun"),

            .init(syllable: "xvan", tone: 3, expected: "xuǎn", note: "xüan -> xuan, a priority"),
            .init(syllable: "qvan", tone: 2, expected: "quán", note: "qüan -> quan, a priority"),
            .init(syllable: "qve", tone: 2, expected: "qué", note: "qüe -> que, e priority"),
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testFinals_Breadth_WY_AndCommon() {
        let cases: [Case] = [
            .init(syllable: "you", tone: 2, expected: "yóu", note: "ou -> o marked"),
            .init(syllable: "wei", tone: 4, expected: "wèi", note: "ei -> e priority"),
            .init(syllable: "wang", tone: 3, expected: "wǎng", note: "a priority"),
            .init(syllable: "ying", tone: 2, expected: "yíng", note: "i marked"),
            .init(syllable: "yong", tone: 3, expected: "yǒng", note: "ong -> o marked"),
            .init(syllable: "zhou", tone: 2, expected: "zhóu", note: "ou -> o marked"),
            .init(syllable: "dou", tone: 3, expected: "dǒu", note: "ou -> o marked")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testNasalAndMedials_Variety() {
        let cases: [Case] = [
            .init(syllable: "pin", tone: 4, expected: "pìn", note: "in -> i marked"),
            .init(syllable: "ming", tone: 2, expected: "míng", note: "ing -> i marked"),
            .init(syllable: "kun", tone: 3, expected: "kǔn", note: "un -> u marked"),
            .init(syllable: "guai", tone: 3, expected: "guǎi", note: "uai -> a priority"),
            .init(syllable: "duan", tone: 4, expected: "duàn", note: "uan -> a priority"),
            .init(syllable: "zhuang", tone: 2, expected: "zhuáng", note: "uang -> a priority")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testUI_IU_AdditionalCoverage() {
        let cases: [Case] = [
            .init(syllable: "jiu", tone: 2, expected: "jiú", note: "iu -> u marked"),
            .init(syllable: "miu", tone: 3, expected: "miǔ", note: "iu -> u marked"),
            .init(syllable: "dui", tone: 4, expected: "duì", note: "ui -> i marked"),
            .init(syllable: "zhui", tone: 3, expected: "zhuǐ", note: "ui -> i marked")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testNeutralTone_BroaderCoverage() {
        let cases: [Case] = [
            .init(syllable: "nv", tone: 5, expected: "nü", note: "neutral keeps ü, no tone"),
            .init(syllable: "yvan", tone: 5, expected: "yuan", note: "neutral, no diaeresis after y"),
            .init(syllable: "shui", tone: 5, expected: "shui", note: "neutral ui"),
            .init(syllable: "er", tone: 5, expected: "er", note: "neutral er")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testCapitalization_TitleCase() {
        let cases: [Case] = [
            .init(syllable: "Ma", tone: 1, expected: "Mā", note: "consonant + a, title case"),
            .init(syllable: "Ai", tone: 2, expected: "Ái", note: "initial vowel capitalized"),
            .init(syllable: "Er", tone: 3, expected: "Ěr", note: "er with uppercase tone"),
            .init(syllable: "Nv", tone: 3, expected: "Nǚ", note: "N + ü retains diaeresis; lowercase ü"),
            .init(syllable: "Lve", tone: 4, expected: "Lüè", note: "lüe; e gets tone"),
            .init(syllable: "Jv", tone: 1, expected: "Jū", note: "J + v -> Ju with tone on u"),
            .init(syllable: "Yvan", tone: 3, expected: "Yuǎn", note: "Y + v -> Yuan; a gets tone"),
            .init(syllable: "Qve", tone: 2, expected: "Qué", note: "Q + v -> Que; e gets tone"),
            .init(syllable: "Zhong", tone: 1, expected: "Zhōng", note: "compound initial, title case"),
            .init(syllable: "Shui", tone: 3, expected: "Shuǐ", note: "ui -> i marked, title case"),
            .init(syllable: "You", tone: 5, expected: "You", note: "neutral tone retains title case")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }

    func testCapitalization_AllCaps() {
        let cases: [Case] = [
            .init(syllable: "MA", tone: 1, expected: "MĀ", note: "all caps a1"),
            .init(syllable: "OU", tone: 4, expected: "ÒU", note: "ou -> o marked, all caps"),
            .init(syllable: "NV", tone: 3, expected: "NǙ", note: "N + V -> N + Ü with tone 3"),
            .init(syllable: "QVE", tone: 2, expected: "QUÉ", note: "after Q, V->U; e gets tone, all caps"),
            .init(syllable: "ZHONG", tone: 1, expected: "ZHŌNG", note: "compound initial, all caps"),
            .init(syllable: "SHUI", tone: 3, expected: "SHUǏ", note: "ui -> i marked, all caps")
        ]

        for c in cases {
            XCTAssertEqual(engine.convert(syllable: c.syllable, tone: c.tone), c.expected, c.note)
        }
    }
}

// A structured, spec-mapped conformance report. This aggregates cases by
// spec aspect (ISO 7098 / GB/T 16159) and produces a single attachment
// summarizing pass/fail counts per aspect, plus details for any failures.
final class SpecConformanceReportTests: XCTestCase {
    struct SpecCase {
        let syllable: String
        let tone: Int
        let expected: String
        let note: String
    }

    struct SpecSection {
        let spec: String   // e.g., "ISO 7098" or "GB/T 16159"
        let title: String  // short description of the aspect
        let cases: [SpecCase]
    }

    func test_Spec_Conformance_Report() {
        let engine = PinyinEngine()

        let sections: [SpecSection] = [
            SpecSection(
                spec: "ISO 7098",
                title: "Tone placement: a/e priority; ou on o; else last vowel",
                cases: [
                    .init(syllable: "ba", tone: 1, expected: "bā", note: "a priority"),
                    .init(syllable: "me", tone: 2, expected: "mé", note: "e priority"),
                    .init(syllable: "li", tone: 3, expected: "lǐ", note: "last vowel i"),
                    .init(syllable: "bo", tone: 4, expected: "bò", note: "last vowel o"),
                    .init(syllable: "lu", tone: 2, expected: "lú", note: "last vowel u"),
                    .init(syllable: "ai", tone: 2, expected: "ái", note: "last vowel i"),
                    .init(syllable: "ei", tone: 3, expected: "ěi", note: "e priority"),
                    .init(syllable: "ao", tone: 4, expected: "ào", note: "a priority"),
                    .init(syllable: "ou", tone: 3, expected: "ǒu", note: "ou -> o"),
                    .init(syllable: "en", tone: 3, expected: "ěn", note: "e priority"),
                    .init(syllable: "ang", tone: 4, expected: "àng", note: "a priority"),
                    .init(syllable: "eng", tone: 2, expected: "éng", note: "e priority"),
                    .init(syllable: "ong", tone: 3, expected: "ǒng", note: "o marked")
                ]
            ),
            SpecSection(
                spec: "ISO 7098",
                title: "UI/IU special: mark last vowel (liù, guī)",
                cases: [
                    .init(syllable: "liu", tone: 4, expected: "liù", note: "iu -> u"),
                    .init(syllable: "niu", tone: 3, expected: "niǔ", note: "iu -> u"),
                    .init(syllable: "gui", tone: 1, expected: "guī", note: "ui -> i"),
                    .init(syllable: "shui", tone: 2, expected: "shuí", note: "ui -> i")
                ]
            ),
            SpecSection(
                spec: "GB/T 16159",
                title: "Apical vowel i (zhi, chi, shi, ri, zi, ci, si)",
                cases: [
                    .init(syllable: "zhi", tone: 1, expected: "zhī", note: "apical i"),
                    .init(syllable: "chi", tone: 2, expected: "chí", note: "apical i"),
                    .init(syllable: "shi", tone: 4, expected: "shì", note: "apical i"),
                    .init(syllable: "ri", tone: 3, expected: "rǐ", note: "apical i"),
                    .init(syllable: "zi", tone: 1, expected: "zī", note: "apical i"),
                    .init(syllable: "ci", tone: 2, expected: "cí", note: "apical i"),
                    .init(syllable: "si", tone: 3, expected: "sǐ", note: "apical i")
                ]
            ),
            SpecSection(
                spec: "GB/T 16159",
                title: "Ü after J/Q/X/Y written as u (ju/jue/juan/jun; yu/yue/yuan/yun)",
                cases: [
                    .init(syllable: "jv", tone: 1, expected: "jū", note: "jü -> ju"),
                    .init(syllable: "jve", tone: 4, expected: "juè", note: "jüe -> jue"),
                    .init(syllable: "jvan", tone: 2, expected: "juán", note: "jüan -> juan"),
                    .init(syllable: "qv", tone: 3, expected: "qǔ", note: "qü -> qu"),
                    .init(syllable: "xve", tone: 2, expected: "xué", note: "xüe -> xue"),
                    .init(syllable: "yv", tone: 2, expected: "yú", note: "yü -> yu"),
                    .init(syllable: "yve", tone: 1, expected: "yuē", note: "yüe -> yue"),
                    .init(syllable: "yvan", tone: 3, expected: "yuǎn", note: "yüan -> yuan"),
                    .init(syllable: "jvn", tone: 2, expected: "jún", note: "jün -> jun"),
                    .init(syllable: "xvn", tone: 4, expected: "xùn", note: "xün -> xun"),
                    .init(syllable: "qvan", tone: 2, expected: "quán", note: "qüan -> quan"),
                    .init(syllable: "qve", tone: 2, expected: "qué", note: "qüe -> que")
                ]
            ),
            SpecSection(
                spec: "GB/T 16159",
                title: "Ü retained for N/L (nü/lü; nüe/lüe)",
                cases: [
                    .init(syllable: "nv", tone: 3, expected: "nǚ", note: "nü retained"),
                    .init(syllable: "lv", tone: 4, expected: "lǜ", note: "lü retained"),
                    .init(syllable: "nve", tone: 2, expected: "nüé", note: "nüe; e gets tone"),
                    .init(syllable: "lve", tone: 4, expected: "lüè", note: "lue; e gets tone")
                ]
            ),
            SpecSection(
                spec: "ISO 7098",
                title: "Y-/W- orthography mapping and tone placement",
                cases: [
                    .init(syllable: "you", tone: 2, expected: "yóu", note: "ou -> o"),
                    .init(syllable: "wei", tone: 4, expected: "wèi", note: "ei -> e"),
                    .init(syllable: "wang", tone: 3, expected: "wǎng", note: "a priority"),
                    .init(syllable: "ying", tone: 2, expected: "yíng", note: "i marked"),
                    .init(syllable: "yong", tone: 3, expected: "yǒng", note: "o marked")
                ]
            ),
            SpecSection(
                spec: "ISO 7098",
                title: "Nasal finals and medials (variety)",
                cases: [
                    .init(syllable: "pin", tone: 4, expected: "pìn", note: "in -> i"),
                    .init(syllable: "ming", tone: 2, expected: "míng", note: "ing -> i"),
                    .init(syllable: "kun", tone: 3, expected: "kǔn", note: "un -> u"),
                    .init(syllable: "guai", tone: 3, expected: "guǎi", note: "uai -> a"),
                    .init(syllable: "duan", tone: 4, expected: "duàn", note: "uan -> a"),
                    .init(syllable: "zhuang", tone: 2, expected: "zhuáng", note: "uang -> a"),
                    .init(syllable: "xiong", tone: 2, expected: "xióng", note: "iong -> o"),
                    .init(syllable: "tuo", tone: 4, expected: "tuò", note: "uo -> o"),
                    .init(syllable: "xia", tone: 2, expected: "xiá", note: "a priority"),
                    .init(syllable: "xie", tone: 4, expected: "xiè", note: "e priority"),
                    .init(syllable: "biao", tone: 1, expected: "biāo", note: "iao -> a"),
                    .init(syllable: "lian", tone: 3, expected: "liǎn", note: "ian -> a"),
                    .init(syllable: "liang", tone: 4, expected: "liàng", note: "iang -> a"),
                    .init(syllable: "lin", tone: 2, expected: "lín", note: "i marked"),
                    .init(syllable: "ting", tone: 3, expected: "tǐng", note: "i marked"),
                    .init(syllable: "lun", tone: 2, expected: "lún", note: "u marked")
                ]
            ),
            SpecSection(
                spec: "ISO 7098",
                title: "Erhua: 'er' takes tone on e",
                cases: [
                    .init(syllable: "er", tone: 1, expected: "ēr", note: "tone 1"),
                    .init(syllable: "er", tone: 2, expected: "ér", note: "tone 2"),
                    .init(syllable: "er", tone: 3, expected: "ěr", note: "tone 3"),
                    .init(syllable: "er", tone: 4, expected: "èr", note: "tone 4")
                ]
            ),
            SpecSection(
                spec: "ISO 7098",
                title: "Neutral tone has no diacritic",
                cases: [
                    .init(syllable: "ma", tone: 5, expected: "ma", note: "neutral"),
                    .init(syllable: "de", tone: 5, expected: "de", note: "neutral"),
                    .init(syllable: "men", tone: 5, expected: "men", note: "neutral"),
                    .init(syllable: "ou", tone: 5, expected: "ou", note: "neutral"),
                    .init(syllable: "nv", tone: 5, expected: "nü", note: "neutral ü retained"),
                    .init(syllable: "yvan", tone: 5, expected: "yuan", note: "neutral ü->u"),
                    .init(syllable: "shui", tone: 5, expected: "shui", note: "neutral ui"),
                    .init(syllable: "er", tone: 5, expected: "er", note: "neutral er")
                ]
            ),
            SpecSection(
                spec: "ISO 7098 / GB/T 16159",
                title: "Capitalization with diacritics (Title Case & ALL CAPS)",
                cases: [
                    .init(syllable: "Ma", tone: 1, expected: "Mā", note: "title case"),
                    .init(syllable: "Ai", tone: 2, expected: "Ái", note: "uppercase diacritic on initial vowel"),
                    .init(syllable: "Er", tone: 3, expected: "Ěr", note: "uppercase diacritic on e"),
                    .init(syllable: "Nv", tone: 3, expected: "Nǚ", note: "N + ü retained"),
                    .init(syllable: "Lve", tone: 4, expected: "Lüè", note: "lüe; e gets tone"),
                    .init(syllable: "Jv", tone: 1, expected: "Jū", note: "J + v -> Ju"),
                    .init(syllable: "Yvan", tone: 3, expected: "Yuǎn", note: "Y + v -> Yuan; a gets tone"),
                    .init(syllable: "Qve", tone: 2, expected: "Qué", note: "Q + v -> Que; e gets tone"),
                    .init(syllable: "Zhong", tone: 1, expected: "Zhōng", note: "compound initial"),
                    .init(syllable: "Shui", tone: 3, expected: "Shuǐ", note: "ui -> i"),
                    .init(syllable: "You", tone: 5, expected: "You", note: "neutral title"),
                    .init(syllable: "MA", tone: 1, expected: "MĀ", note: "ALL CAPS"),
                    .init(syllable: "OU", tone: 4, expected: "ÒU", note: "ALL CAPS"),
                    .init(syllable: "NV", tone: 3, expected: "NǙ", note: "ALL CAPS N + V -> N + Ü"),
                    .init(syllable: "QVE", tone: 2, expected: "QUÉ", note: "ALL CAPS after Q; e gets tone"),
                    .init(syllable: "ZHONG", tone: 1, expected: "ZHŌNG", note: "ALL CAPS"),
                    .init(syllable: "SHUI", tone: 3, expected: "SHUǏ", note: "ALL CAPS ui -> i")
                ]
            )
        ]

        var report = "Spec Conformance Report (GB/T 16159 & ISO 7098)\n"
        var totalFailures = 0

        for section in sections {
            var passes = 0
            var fails = 0
            var failDetails: [String] = []

            for c in section.cases {
                let got = engine.convert(syllable: c.syllable, tone: c.tone)
                if got == c.expected {
                    passes += 1
                } else {
                    fails += 1
                    let detail = "  - FAIL: \(section.spec) — \(section.title): \(c.syllable) +\(c.tone) expected \(c.expected) got \(got) [\(c.note)]"
                    failDetails.append(detail)
                }
            }

            totalFailures += fails
            let status = fails == 0 ? "PASS" : "FAIL"
            report += "- [\(status)] \(section.spec) — \(section.title): \(passes)/\(section.cases.count)\n"
            if !failDetails.isEmpty {
                report += failDetails.joined(separator: "\n") + "\n"
            }
        }

        let attachment = XCTAttachment(string: report)
        attachment.name = "Spec Conformance Report"
        attachment.lifetime = .keepAlways
        add(attachment)
        print(report)

        if totalFailures > 0 {
            XCTFail("Spec conformance failures detected. See report attachment.")
        }
    }
}
