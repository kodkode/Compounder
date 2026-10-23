import Foundation

/// Number formatting for the current language and currency.
struct Fmt {
    let currency: AppCurrency
    let language: AppLanguage

    private static let posix = Locale(identifier: "en_US_POSIX")

    func money(_ value: Double, cents: Bool = false) -> String {
        value.formatted(
            .currency(code: currency.rawValue)
                .locale(language.locale)
                .precision(.fractionLength(cents ? 2 : 0))
        )
    }

    /// Compact amount for tight spots: ₪50K, ₪1.25M.
    func short(_ value: Double) -> String {
        let magnitude = abs(value)
        let sign = value < 0 ? "-" : ""
        if magnitude >= 1_000_000 {
            return sign + currency.symbol + plain(magnitude / 1_000_000, maxDigits: 2) + "M"
        }
        if magnitude >= 10_000 {
            return sign + currency.symbol + plain(magnitude / 1_000, maxDigits: 1) + "K"
        }
        return money(value)
    }

    func percent(_ value: Double, digits: ClosedRange<Int>) -> String {
        value.formatted(.number.precision(.fractionLength(digits)).locale(Fmt.posix)) + "%"
    }

    func plain(_ value: Double, maxDigits: Int) -> String {
        value.formatted(.number.precision(.fractionLength(0...maxDigits)).grouping(.never).locale(Fmt.posix))
    }

    func years(_ count: Int) -> String {
        Strings(language: language).years(count)
    }

    func value(_ kind: FieldKind, _ value: Double, short isShort: Bool) -> String {
        switch kind {
        case .money: return isShort ? short(value) : money(value)
        case .percent0: return percent(value, digits: 0...0)
        case .percent1: return percent(value, digits: 1...1)
        case .percent2: return percent(value, digits: 1...2)
        case .years: return isShort ? String(Int(value)) : years(Int(value))
        }
    }

    func date(_ date: Date) -> String {
        date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year().locale(language.locale))
    }
}
