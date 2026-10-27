import Foundation

enum AppLocalization {
    static func text(_ key: String, fallback: String? = nil, locale: Locale = .current) -> String {
        let language = locale.language.languageCode?.identifier == "zh" ? "zh-Hans" : "en"
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return fallback ?? key }
        return bundle.localizedString(forKey: key, value: fallback ?? key, table: "Localizable")
    }
}
