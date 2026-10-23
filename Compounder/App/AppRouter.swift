import SwiftUI

enum AppTab: Hashable {
    case home, compare, calculator, saved, settings
}

/// Navigation plus the calculator and compare inputs, kept here so they survive
/// switching tabs.
final class AppRouter: ObservableObject {
    @Published var tab: AppTab = .home

    @Published var mode: CalcMode = .savings
    @Published var savings = SavingsInput.standard
    @Published var mortgage = MortgageInput.standard
    @Published var amountsHidden = false

    @Published var compareMode: CalcMode = .savings
    @Published var compareSavings = [
        SavingsInput(initial: 50_000, monthly: 1_000, annualRate: 6, years: 20),
        SavingsInput(initial: 50_000, monthly: 1_500, annualRate: 5, years: 20)
    ]
    @Published var compareMortgage = [
        MortgageInput(price: 2_000_000, downPercent: 25, annualRate: 4.5, years: 25),
        MortgageInput(price: 2_000_000, downPercent: 25, annualRate: 4.9, years: 20)
    ]
    /// 0 = scenario A, 1 = scenario B.
    @Published var compareSelection = 0

    private var didLaunch = false

    func launch(hideAmounts: Bool) {
        guard !didLaunch else { return }
        didLaunch = true
        amountsHidden = hideAmounts
    }

    func startNew(_ mode: CalcMode) {
        self.mode = mode
        tab = .calculator
    }

    func open(_ scenario: Scenario) {
        switch scenario.kind {
        case .savings: savings = scenario.savingsInput
        case .mortgage: mortgage = scenario.mortgageInput
        }
        mode = scenario.kind
        tab = .calculator
    }
}
