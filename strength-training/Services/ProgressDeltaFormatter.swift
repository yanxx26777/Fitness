import Foundation

enum ProgressDeltaFormatter {
    /// Direction is rendered separately; unavailable data has no numeric magnitude.
    static func percentMagnitude(_ percent: Double, locale: Locale = .current) -> String {
        guard percent.isFinite else { return "—" }
        let magnitude = abs(percent).rounded()
        let maximum = 9_999.0
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        guard let formatted = formatter.string(from: NSNumber(value: min(magnitude, maximum) / 100)) else {
            return "—"
        }
        return magnitude > maximum ? "≥" + formatted : formatted
    }
}
