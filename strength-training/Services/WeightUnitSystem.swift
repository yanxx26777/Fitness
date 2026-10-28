import Foundation

enum WeightUnitSystem: String, CaseIterable {
    case metric, imperial
    static let poundsPerKilogram = 2.2046226218
    static func resolve(rawValue: String?) -> Self { rawValue.flatMap(Self.init(rawValue:)) ?? .metric }
    static var current: Self { resolve(rawValue: UserDefaults.standard.string(forKey: "weightUnitSystem")) }
    var symbol: String { self == .metric ? "kg" : "lb" }
    var inputStep: Double { self == .metric ? 2.5 : 5 }
    func fromStoredPounds(_ value: Double) -> Double { self == .metric ? value / Self.poundsPerKilogram : value }
    func toStoredPounds(_ value: Double) -> Double { self == .metric ? value * Self.poundsPerKilogram : value }
    /// Apply input limits to newly logged weights without modifying restored history.
    static func normalizedInputStoredPounds(_ value: Double) -> Double {
        value.isNaN || value < 0 ? 0 : min(value, 10_000)
    }
    func displayWeight(fromStoredPounds value: Double) -> Double {
        fromStoredPounds(Self.normalizedInputStoredPounds(value))
    }
    func formatSignedStoredPounds(_ value: Double) -> String {
        let sign = value > 0 ? "+" : value < 0 ? "−" : ""
        return sign + formatStoredPounds(abs(value))
    }
    func formatStoredPounds(_ value: Double, maximumFractionDigits: Int = 1) -> String {
        return Self.format(displayWeight(fromStoredPounds: value), maximumFractionDigits: maximumFractionDigits)
    }
    static func format(_ value: Double, maximumFractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value.isFinite ? max(0, value) : 0)) ?? "0"
    }
}
