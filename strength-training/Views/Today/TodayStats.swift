//
//  TodayStats.swift
//  strength-training
//
//  Pure date/format helpers for the Today screen — unit-tested, no SwiftData.
//

import Foundation

enum TodayStats {

    // MARK: - Relative day label

    /// Section-header label for the most recent completed session.
    /// Same day → "Today"; 1 day ago → "Yesterday"; 2–6 days → weekday name;
    /// 7+ days → "N days ago". (Rendered uppercase by SectionHeader.)
    static func relativeDayLabel(for date: Date, now: Date = .now, calendar: Calendar = .current, locale: Locale = .current) -> String {
        let startNow = calendar.startOfDay(for: now)
        let startDate = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDate, to: startNow).day ?? 0
        switch days {
        case ..<1:
            return AppLocalization.text("Today", locale: locale)
        case 1:
            return AppLocalization.text("Yesterday", locale: locale)
        case 2...6:
            let formatter = DateFormatter()
            formatter.calendar = calendar
            formatter.timeZone = calendar.timeZone
            formatter.locale = locale
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        default:
            return String(format: AppLocalization.text("%lld days ago", locale: locale), locale: locale, days)
        }
    }

    // MARK: - Week grid

    struct WeekDayCell: Equatable {
        let letter: String       // "M", "T", …
        let trained: DayType?    // day-type ink fill when non-nil
        let isToday: Bool
    }

    /// Seven cells for the current Monday-start week. A day trained more than
    /// once shows its most recent session's day type.
    static func weekCells(
        sessions: [(date: Date, dayType: DayType)],
        now: Date = .now,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> [WeekDayCell] {
        var cal = calendar
        cal.firstWeekday = 2   // Monday
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }

        let letters = locale.language.languageCode?.identifier == "zh"
            ? ["一", "二", "三", "四", "五", "六", "日"] : ["M", "T", "W", "T", "F", "S", "S"]
        return (0..<7).map { offset in
            let dayDate = cal.date(byAdding: .day, value: offset, to: weekStart)!
            let trained = sessions
                .filter { cal.isDate($0.date, inSameDayAs: dayDate) }
                .max { $0.date < $1.date }?
                .dayType
            return WeekDayCell(
                letter: letters[offset],
                trained: trained,
                isToday: cal.isDate(dayDate, inSameDayAs: now)
            )
        }
    }

    // MARK: - Volume formatting

    /// "12,840" — grouped, no fraction (rounded).
    static func formatVolume(_ lbs: Double, unit: WeightUnitSystem = .current) -> String {
        WeightUnitSystem.format(unit.fromStoredPounds(lbs), maximumFractionDigits: 0)
    }

    static func formatCompactVolume(_ lbs: Double, unit: WeightUnitSystem = .current) -> String {
        let value = unit.fromStoredPounds(lbs)
        return value.isFinite && value >= 10_000
            ? "\(Int(min(value / 1000, Double(Int.max / 2)).rounded()))k"
            : formatVolume(lbs, unit: unit)
    }
}
