import Foundation
import SwiftData

enum CalcMode: String, Codable, Hashable {
    case savings
    case mortgage
}

/// A saved calculation. Inputs are stored flat (both kinds) to keep the
/// SwiftData schema simple; `kind` says which set is meaningful.
@Model
final class Scenario {
    var name: String
    var kindRaw: String
    var themeRaw: String
    var createdAt: Date

    var initial: Double
    var monthly: Double
    var savingsRate: Double
    var savingsYears: Int

    var price: Double
    var downPercent: Double
    var mortgageRate: Double
    var mortgageYears: Int

    init(name: String, kind: CalcMode, theme: CardTheme, savings: SavingsInput, mortgage: MortgageInput, createdAt: Date = .now) {
        self.name = name
        self.kindRaw = kind.rawValue
        self.themeRaw = theme.rawValue
        self.createdAt = createdAt
        self.initial = savings.initial
        self.monthly = savings.monthly
        self.savingsRate = savings.annualRate
        self.savingsYears = savings.years
        self.price = mortgage.price
        self.downPercent = mortgage.downPercent
        self.mortgageRate = mortgage.annualRate
        self.mortgageYears = mortgage.years
    }

    var kind: CalcMode { CalcMode(rawValue: kindRaw) ?? .savings }
    var theme: CardTheme { CardTheme(rawValue: themeRaw) ?? .sunset }

    var savingsInput: SavingsInput {
        SavingsInput(initial: initial, monthly: monthly, annualRate: savingsRate, years: savingsYears)
    }

    var mortgageInput: MortgageInput {
        MortgageInput(price: price, downPercent: downPercent, annualRate: mortgageRate, years: mortgageYears)
    }
}

extension Scenario {
    struct Summary {
        let value: String
        let unit: String
        let meta: String
    }

    func summary(settings: AppSettings) -> Summary {
        let t = settings.strings
        let fmt = settings.fmt
        switch kind {
        case .savings:
            let input = savingsInput
            let result = Finance.savings(input, compounding: settings.compounding, depositAtStart: settings.depositAtStart)
            return Summary(
                value: fmt.short(result.futureValue),
                unit: t.inYears(input.years),
                meta: t.savingsMeta(monthly: fmt.money(input.monthly), rate: fmt.percent(input.annualRate, digits: 1...1), years: input.years)
            )
        case .mortgage:
            let input = mortgageInput
            let result = Finance.mortgage(input)
            return Summary(
                value: fmt.money(result.monthlyPayment),
                unit: t.perMonthOver(input.years),
                meta: t.mortgageMeta(price: fmt.short(input.price), down: fmt.percent(input.downPercent, digits: 0...0), rate: fmt.percent(input.annualRate, digits: 1...2))
            )
        }
    }
}
