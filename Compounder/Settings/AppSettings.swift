import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case hebrew = "he"
    case english = "en"

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .hebrew: return Locale(identifier: "he_IL")
        case .english: return Locale(identifier: "en_IL")
        }
    }

    var layoutDirection: LayoutDirection {
        self == .hebrew ? .rightToLeft : .leftToRight
    }

    /// Always shown in its own language.
    var nativeName: String {
        self == .hebrew ? "עברית" : "English"
    }
}

enum AppCurrency: String, CaseIterable, Identifiable {
    case ils = "ILS"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .ils: return "₪"
        case .usd: return "$"
        case .eur: return "€"
        }
    }
}

/// User preferences, persisted to UserDefaults.
final class AppSettings: ObservableObject {
    private enum Key {
        static let language = "settings.language"
        static let currency = "settings.currency"
        static let compounding = "settings.compounding"
        static let depositAtStart = "settings.depositAtStart"
        static let hideAmountsOnLaunch = "settings.hideAmountsOnLaunch"
    }

    private let defaults: UserDefaults

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Key.language) }
    }
    @Published var currency: AppCurrency {
        didSet { defaults.set(currency.rawValue, forKey: Key.currency) }
    }
    @Published var compounding: Compounding {
        didSet { defaults.set(compounding.rawValue, forKey: Key.compounding) }
    }
    @Published var depositAtStart: Bool {
        didSet { defaults.set(depositAtStart, forKey: Key.depositAtStart) }
    }
    @Published var hideAmountsOnLaunch: Bool {
        didSet { defaults.set(hideAmountsOnLaunch, forKey: Key.hideAmountsOnLaunch) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        language = AppLanguage(rawValue: defaults.string(forKey: Key.language) ?? "") ?? .hebrew
        currency = AppCurrency(rawValue: defaults.string(forKey: Key.currency) ?? "") ?? .ils
        compounding = Compounding(rawValue: defaults.string(forKey: Key.compounding) ?? "") ?? .monthly
        depositAtStart = defaults.bool(forKey: Key.depositAtStart)
        hideAmountsOnLaunch = defaults.bool(forKey: Key.hideAmountsOnLaunch)
    }

    var strings: Strings { Strings(language: language) }
    var fmt: Fmt { Fmt(currency: currency, language: language) }
}

/// Applies the chosen language's direction and locale. Use on the root view and
/// on sheet contents.
struct LocalizedEnvironment: ViewModifier {
    @EnvironmentObject private var settings: AppSettings

    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, settings.language.layoutDirection)
            .environment(\.locale, settings.language.locale)
            .preferredColorScheme(.dark)
            .tint(Theme.accent)
    }
}

extension View {
    func localizedEnvironment() -> some View {
        modifier(LocalizedEnvironment())
    }
}
