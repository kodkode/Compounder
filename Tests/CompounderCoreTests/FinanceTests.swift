import XCTest
@testable import CompounderCore

final class SavingsTests: XCTestCase {
    func testZeroRateReturnsDeposits() {
        let result = Finance.savings(SavingsInput(initial: 1_000, monthly: 100, annualRate: 0, years: 2))
        XCTAssertEqual(result.futureValue, 3_400, accuracy: 0.0001)
        XCTAssertEqual(result.totalDeposited, 3_400, accuracy: 0.0001)
        XCTAssertEqual(result.interestEarned, 0, accuracy: 0.0001)
    }

    func testLumpSumMonthlyCompounding() {
        // 10,000 × 1.01^12
        let result = Finance.savings(SavingsInput(initial: 10_000, monthly: 0, annualRate: 12, years: 1))
        XCTAssertEqual(result.futureValue, 11_268.25, accuracy: 0.01)
    }

    func testLumpSumYearlyCompounding() {
        let result = Finance.savings(
            SavingsInput(initial: 10_000, monthly: 0, annualRate: 12, years: 2),
            compounding: .yearly
        )
        XCTAssertEqual(result.futureValue, 12_544, accuracy: 0.01)
    }

    func testOrdinaryAnnuity() {
        // 100 × ((1.01^12 − 1) / 0.01)
        let result = Finance.savings(SavingsInput(initial: 0, monthly: 100, annualRate: 12, years: 1))
        XCTAssertEqual(result.futureValue, 1_268.25, accuracy: 0.01)
        XCTAssertEqual(result.totalDeposited, 1_200, accuracy: 0.0001)
    }

    func testAnnuityDue() {
        let result = Finance.savings(
            SavingsInput(initial: 0, monthly: 100, annualRate: 12, years: 1),
            depositAtStart: true
        )
        XCTAssertEqual(result.futureValue, 1_280.93, accuracy: 0.01)
    }

    func testTimelineIsConsistent() {
        let result = Finance.savings(.standard)
        XCTAssertEqual(result.timeline.count, SavingsInput.standard.years + 1)
        XCTAssertEqual(result.timeline.first?.balance, SavingsInput.standard.initial)
        XCTAssertEqual(result.timeline.last?.balance ?? 0, result.futureValue, accuracy: 0.0001)
        let interestSum = result.timeline.reduce(0) { $0 + $1.interest }
        XCTAssertEqual(interestSum, result.interestEarned, accuracy: 0.01)
    }

    func testZeroYears() {
        let result = Finance.savings(SavingsInput(initial: 5_000, monthly: 100, annualRate: 5, years: 0))
        XCTAssertEqual(result.futureValue, 5_000)
        XCTAssertEqual(result.timeline.count, 1)
    }
}

final class MortgageTests: XCTestCase {
    func testStandardPayment() {
        let payment = Finance.monthlyPayment(loan: 100_000, annualRate: 6, months: 360)
        XCTAssertEqual(payment, 599.55, accuracy: 0.01)
    }

    func testZeroRatePayment() {
        let payment = Finance.monthlyPayment(loan: 120_000, annualRate: 0, months: 120)
        XCTAssertEqual(payment, 1_000, accuracy: 0.0001)
    }

    func testScheduleRepaysLoan() {
        let input = MortgageInput(price: 2_000_000, downPercent: 25, annualRate: 4.5, years: 25)
        let result = Finance.mortgage(input)
        XCTAssertEqual(result.loan, 1_500_000, accuracy: 0.0001)
        XCTAssertEqual(result.downPayment, 500_000, accuracy: 0.0001)
        XCTAssertEqual(result.schedule.count, 25)
        XCTAssertEqual(result.schedule.last?.balance ?? -1, 0, accuracy: 0.01)

        let principalSum = result.schedule.reduce(0) { $0 + $1.principal }
        XCTAssertEqual(principalSum, result.loan, accuracy: 0.01)

        let paid = result.monthlyPayment * Double(input.years * 12)
        XCTAssertEqual(result.totalPayments, paid, accuracy: 0.05)
        XCTAssertEqual(result.totalCost, input.price + result.totalInterest, accuracy: 0.05)
    }

    func testFullDownPaymentMeansNoLoan() {
        let result = Finance.mortgage(MortgageInput(price: 1_000_000, downPercent: 100, annualRate: 5, years: 20))
        XCTAssertEqual(result.loan, 0)
        XCTAssertEqual(result.monthlyPayment, 0)
        XCTAssertEqual(result.totalInterest, 0)
    }

    func testRuleOf72() {
        XCTAssertEqual(Finance.ruleOf72(annualRate: 6), 12, accuracy: 0.0001)
        XCTAssertTrue(Finance.ruleOf72(annualRate: 0).isInfinite)
    }
}
