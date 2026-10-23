import Foundation

// Pure calculation engine. Foundation only — shared by the app target and the
// `CompounderCore` Swift package so it can be unit-tested with `swift test`.

public enum Compounding: String, CaseIterable, Codable, Sendable {
    /// Interest is credited to the balance every month.
    case monthly
    /// Interest accrues monthly but is credited once a year.
    case yearly
}

// MARK: - Savings

public struct SavingsInput: Codable, Hashable, Sendable {
    public var initial: Double
    public var monthly: Double
    /// Annual rate in percent (6 means 6%).
    public var annualRate: Double
    public var years: Int

    public init(initial: Double, monthly: Double, annualRate: Double, years: Int) {
        self.initial = initial
        self.monthly = monthly
        self.annualRate = annualRate
        self.years = years
    }

    public static let standard = SavingsInput(initial: 50_000, monthly: 1_000, annualRate: 6, years: 20)
}

public struct SavingsYear: Hashable, Sendable, Identifiable {
    public let year: Int
    public let balance: Double
    public let deposited: Double
    /// Interest earned during this year.
    public let interest: Double
    public var id: Int { year }
}

public struct SavingsResult: Hashable, Sendable {
    public let futureValue: Double
    public let totalDeposited: Double
    /// Year 0 (today) through the final year.
    public let timeline: [SavingsYear]

    public var interestEarned: Double { max(0, futureValue - totalDeposited) }
    public var multiplier: Double { totalDeposited > 0 ? futureValue / totalDeposited : 1 }
}

// MARK: - Mortgage

public struct MortgageInput: Codable, Hashable, Sendable {
    public var price: Double
    /// Down payment as a percent of the price (25 means 25%).
    public var downPercent: Double
    /// Annual rate in percent.
    public var annualRate: Double
    public var years: Int

    public init(price: Double, downPercent: Double, annualRate: Double, years: Int) {
        self.price = price
        self.downPercent = downPercent
        self.annualRate = annualRate
        self.years = years
    }

    public var downPayment: Double { max(0, price) * min(max(downPercent, 0), 100) / 100 }
    public var loanAmount: Double { max(0, price) - downPayment }

    public static let standard = MortgageInput(price: 2_000_000, downPercent: 25, annualRate: 4.5, years: 25)
}

public struct MortgageYear: Hashable, Sendable, Identifiable {
    public let year: Int
    public let principal: Double
    public let interest: Double
    /// Remaining balance at the end of the year.
    public let balance: Double
    public var id: Int { year }
}

public struct MortgageResult: Hashable, Sendable {
    public let loan: Double
    public let downPayment: Double
    public let monthlyPayment: Double
    public let totalInterest: Double
    public let schedule: [MortgageYear]

    public var totalPayments: Double { loan + totalInterest }
    public var totalCost: Double { downPayment + totalPayments }
}

// MARK: - Engine

public enum Finance {
    public static func savings(
        _ input: SavingsInput,
        compounding: Compounding = .monthly,
        depositAtStart: Bool = false
    ) -> SavingsResult {
        let rate = max(0, input.annualRate) / 100
        let monthly = max(0, input.monthly)
        var balance = max(0, input.initial)
        var deposited = balance
        var timeline = [SavingsYear(year: 0, balance: balance, deposited: deposited, interest: 0)]

        for year in stride(from: 1, through: max(0, input.years), by: 1) {
            var earned = 0.0
            var accrued = 0.0
            for _ in 0..<12 {
                if depositAtStart {
                    balance += monthly
                    deposited += monthly
                }
                let interest = balance * rate / 12
                earned += interest
                switch compounding {
                case .monthly: balance += interest
                case .yearly: accrued += interest
                }
                if !depositAtStart {
                    balance += monthly
                    deposited += monthly
                }
            }
            balance += accrued
            timeline.append(SavingsYear(year: year, balance: balance, deposited: deposited, interest: earned))
        }

        return SavingsResult(futureValue: balance, totalDeposited: deposited, timeline: timeline)
    }

    /// Fixed (Spitzer) monthly payment for a loan.
    public static func monthlyPayment(loan: Double, annualRate: Double, months: Int) -> Double {
        guard loan > 0, months > 0 else { return 0 }
        let r = max(0, annualRate) / 100 / 12
        guard r > 0 else { return loan / Double(months) }
        return loan * r / (1 - pow(1 + r, -Double(months)))
    }

    public static func mortgage(_ input: MortgageInput) -> MortgageResult {
        let loan = input.loanAmount
        let years = max(0, input.years)
        let payment = monthlyPayment(loan: loan, annualRate: input.annualRate, months: years * 12)
        let r = max(0, input.annualRate) / 100 / 12

        var balance = loan
        var totalInterest = 0.0
        var schedule: [MortgageYear] = []
        for year in stride(from: 1, through: years, by: 1) {
            var principalPaid = 0.0
            var interestPaid = 0.0
            for _ in 0..<12 where balance > 0 {
                let interest = balance * r
                let principal = min(balance, payment - interest)
                balance -= principal
                principalPaid += principal
                interestPaid += interest
            }
            if balance < 0.005 { balance = 0 }
            totalInterest += interestPaid
            schedule.append(MortgageYear(year: year, principal: principalPaid, interest: interestPaid, balance: balance))
        }

        return MortgageResult(
            loan: loan,
            downPayment: input.downPayment,
            monthlyPayment: payment,
            totalInterest: totalInterest,
            schedule: schedule
        )
    }

    /// Rule of 72: approximate years for money to double at `annualRate` percent.
    public static func ruleOf72(annualRate: Double) -> Double {
        annualRate > 0 ? 72 / annualRate : .infinity
    }
}
