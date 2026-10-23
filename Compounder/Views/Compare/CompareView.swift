import SwiftUI

struct CompareView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var router: AppRouter
    @State private var editing: FieldSpec?

    private var t: Strings { settings.strings }
    private var fmt: Fmt { settings.fmt }
    private let startYear = Calendar.current.component(.year, from: .now)

    private struct Side {
        let tag: String
        let color: Color
        let value: String
        let unit: String
        let meta: String
        let series: [Double]
    }

    var body: some View {
        let isSavings = router.compareMode == .savings
        let sides = isSavings ? savingsSides() : mortgageSides()
        let verdict = isSavings ? savingsVerdict() : mortgageVerdict()
        let selected = router.compareSelection
        let selectedColor = selected == 0 ? Theme.accent : Theme.purple

        ScreenScroll {
            ScreenHeader(title: t.compareTitle) {
                Button(action: swap) {
                    IconButtonLabel(systemName: "arrow.up.arrow.down")
                }
                .accessibilityLabel(t.swapScenarios)
            } trailing: {
                ShareLink(item: verdict.title + "\n" + verdict.subtitle) {
                    IconButtonLabel(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel(t.share)
            }

            PillSegment(selection: $router.compareMode, options: [
                SegmentOption(value: .savings, label: t.savings),
                SegmentOption(value: .mortgage, label: t.mortgage)
            ])

            HStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { index in
                    sideCard(sides[index], isOn: index == selected) {
                        withAnimation(.snappy) { router.compareSelection = index }
                    }
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.onAccent)
                    .frame(width: 36, height: 36)
                    .background(verdict.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(verdict.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(verdict.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSoft)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(verdict.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .accessibilityElement(children: .combine)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(isSavings ? t.chartSavingsTitle : t.chartLoanBalance)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    LegendItem(color: Theme.accent, label: t.tagA)
                    LegendItem(color: Theme.purple, label: t.tagB)
                }
                GrowthChart(
                    points: chartPoints(sides[0].series, sides[1].series),
                    primaryColor: Theme.accent,
                    secondaryColor: Theme.purple,
                    fillPrimary: false,
                    secondaryDashed: false,
                    startYear: startYear,
                    fmt: fmt
                )
            }
            .padding(16)
            .cardBackground()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle().fill(selectedColor).frame(width: 10, height: 10)
                    Text(t.editing(t.scenarioLabel(selected == 0 ? t.tagA : t.tagB)))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                }
                .padding(.top, 4)
                ForEach(fields(for: selected)) { spec in
                    SliderRow(spec: spec, fmt: fmt, tint: selectedColor) { editing = $0 }
                }
            }
        }
        .fieldEditor($editing)
    }

    // MARK: Pieces

    private func sideCard(_ side: Side, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(side.tag)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.onAccent)
                        .frame(width: 28, height: 28)
                        .background(side.color, in: Circle())
                    Text(t.scenarioLabel(side.tag))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSoft)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(side.value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                    Text(side.unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                }
                Rectangle().fill(Theme.divider).frame(height: 1)
                Text(side.meta)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .cardBackground()
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(isOn ? side.color : .clear, lineWidth: 2)
            )
            .animation(.snappy(duration: 0.25), value: side.value)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func fields(for index: Int) -> [FieldSpec] {
        switch router.compareMode {
        case .savings: return Fields.savings($router.compareSavings[index], t: t)
        case .mortgage: return Fields.mortgage($router.compareMortgage[index], t: t)
        }
    }

    private func chartPoints(_ a: [Double], _ b: [Double]) -> [ChartPoint] {
        let count = max(a.count, b.count)
        return (0..<count).map { year in
            ChartPoint(
                year: year,
                primary: year < a.count ? a[year] : (a.last ?? 0),
                secondary: year < b.count ? b[year] : (b.last ?? 0)
            )
        }
    }

    private func swap() {
        withAnimation(.snappy) {
            router.compareSavings.reverse()
            router.compareMortgage.reverse()
        }
    }

    // MARK: Savings

    private func savingsResults() -> [SavingsResult] {
        router.compareSavings.map {
            Finance.savings($0, compounding: settings.compounding, depositAtStart: settings.depositAtStart)
        }
    }

    private func savingsSides() -> [Side] {
        let results = savingsResults()
        return (0..<2).map { index in
            let input = router.compareSavings[index]
            let result = results[index]
            return Side(
                tag: index == 0 ? t.tagA : t.tagB,
                color: index == 0 ? Theme.accent : Theme.purple,
                value: fmt.short(result.futureValue),
                unit: t.inYears(input.years),
                meta: t.savingsMeta(monthly: fmt.money(input.monthly), rate: fmt.percent(input.annualRate, digits: 1...1), years: input.years),
                series: result.timeline.map(\.balance)
            )
        }
    }

    private func savingsVerdict() -> (title: String, subtitle: String, color: Color) {
        let results = savingsResults()
        let a = results[0].futureValue
        let b = results[1].futureValue
        let subtitle = t.interestComparison(fmt.short(results[0].interestEarned), fmt.short(results[1].interestEarned))
        if abs(a - b) < 1 { return (t.tie, subtitle, Theme.secondary) }
        let aWins = a > b
        return (t.leadsBy(aWins ? t.tagA : t.tagB, fmt.short(abs(a - b))), subtitle, aWins ? Theme.accent : Theme.purple)
    }

    // MARK: Mortgage

    private func mortgageResults() -> [MortgageResult] {
        router.compareMortgage.map { Finance.mortgage($0) }
    }

    private func mortgageSides() -> [Side] {
        let results = mortgageResults()
        return (0..<2).map { index in
            let input = router.compareMortgage[index]
            let result = results[index]
            return Side(
                tag: index == 0 ? t.tagA : t.tagB,
                color: index == 0 ? Theme.accent : Theme.purple,
                value: fmt.money(result.monthlyPayment),
                unit: t.perMonthOver(input.years),
                meta: t.mortgageMeta(price: fmt.short(input.price), down: fmt.percent(input.downPercent, digits: 0...0), rate: fmt.percent(input.annualRate, digits: 1...2)),
                series: [result.loan] + result.schedule.map(\.balance)
            )
        }
    }

    private func mortgageVerdict() -> (title: String, subtitle: String, color: Color) {
        let results = mortgageResults()
        let a = results[0].totalCost
        let b = results[1].totalCost
        let subtitle = t.paymentDifference(fmt.money(abs(results[0].monthlyPayment - results[1].monthlyPayment)))
        if abs(a - b) < 1 { return (t.tie, subtitle, Theme.secondary) }
        let aWins = a < b
        return (t.savesBy(aWins ? t.tagA : t.tagB, fmt.short(abs(a - b))), subtitle, aWins ? Theme.accent : Theme.purple)
    }
}
