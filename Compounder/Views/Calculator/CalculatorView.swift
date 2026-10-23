import SwiftUI
import SwiftData

enum DetailTab: Hashable {
    case chart, schedule, adjust
}

struct ScheduleRow: Identifiable {
    let id: Int
    let title: String
    let right: String
    let rightColor: Color
    let dotColor: Color
    let left2: String
    let right2: String
}

/// Everything the calculator screen shows for the current mode.
struct CalcSummary {
    var hero: String
    var heroSuffix: String
    var heroSub: String
    var planName: String
    var theme: CardTheme
    var cardValues: [CardValue]
    var footer: [CardValue]
    var badge: String
    var chartTitle: String
    var chartPeak: String
    var legendPrimary: String
    var legendSecondary: String
    var points: [ChartPoint]
    var stats: [CardValue]
    var rows: [ScheduleRow]
    var note: String
    var fields: [FieldSpec]
    var shareText: String
}

struct CalculatorView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext

    @State private var savingsDetail: DetailTab = .chart
    @State private var mortgageDetail: DetailTab = .schedule
    @State private var showSaveSheet = false
    @State private var showToast = false
    @State private var editing: FieldSpec?

    private var t: Strings { settings.strings }
    private var fmt: Fmt { settings.fmt }
    private let startYear = Calendar.current.component(.year, from: .now)

    private var detail: Binding<DetailTab> {
        router.mode == .savings ? $savingsDetail : $mortgageDetail
    }

    var body: some View {
        let summary = router.mode == .savings ? savingsSummary() : mortgageSummary()

        ScreenScroll {
            ScreenHeader(title: t.calculatorTitle) {
                Button { showSaveSheet = true } label: {
                    IconButtonLabel(systemName: "bookmark")
                }
                .accessibilityLabel(t.saveScenario)
            } trailing: {
                ShareLink(item: summary.shareText) {
                    IconButtonLabel(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel(t.share)
            }

            PillSegment(selection: $router.mode, options: [
                SegmentOption(value: .savings, label: t.savings),
                SegmentOption(value: .mortgage, label: t.mortgage)
            ])

            heroRow(summary)

            Button {
                withAnimation(.snappy) { detail.wrappedValue = .adjust }
            } label: {
                PlanCard(
                    theme: summary.theme,
                    planName: summary.planName,
                    values: summary.cardValues,
                    footer: summary.footer,
                    badge: summary.badge
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint(t.editInputs)
            .padding(.vertical, 4)

            PillSegment(selection: detail, options: [
                SegmentOption(value: .chart, label: router.mode == .savings ? t.detailGrowth : t.detailChart),
                SegmentOption(value: .schedule, label: router.mode == .savings ? t.detailByYear : t.detailSchedule),
                SegmentOption(value: .adjust, label: t.detailAdjust)
            ], height: 44, fontSize: 14)

            switch detail.wrappedValue {
            case .chart: chartSection(summary)
            case .schedule: scheduleSection(summary)
            case .adjust: adjustSection(summary)
            }
        }
        .fieldEditor($editing)
        .sheet(isPresented: $showSaveSheet) {
            SaveScenarioSheet(
                theme: summary.theme,
                title: summary.hero + (summary.heroSuffix.isEmpty ? "" : " " + summary.heroSuffix),
                subtitle: summary.cardValues.map(\.value).joined(separator: " · "),
                defaultName: defaultName(),
                onSave: save
            )
            .environmentObject(settings)
        }
        .overlay(alignment: .top) {
            if showToast {
                ToastView(text: t.savedToast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sensoryFeedback(.success, trigger: showToast) { _, new in new }
    }

    // MARK: Sections

    private func heroRow(_ summary: CalcSummary) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(mask(summary.hero))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                    if !summary.heroSuffix.isEmpty {
                        Text(summary.heroSuffix)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.secondary)
                    }
                }
                Text(mask(summary.heroSub))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .animation(.snappy(duration: 0.25), value: summary.hero)
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                Button {
                    withAnimation(.snappy) { router.amountsHidden.toggle() }
                } label: {
                    IconButtonLabel(systemName: router.amountsHidden ? "eye.slash" : "eye", circle: true)
                }
                .accessibilityLabel(router.amountsHidden ? t.showAmounts : t.hideAmounts)

                Button {
                    withAnimation(.snappy) { detail.wrappedValue = .adjust }
                } label: {
                    IconButtonLabel(systemName: "slider.horizontal.3", circle: true)
                }
                .accessibilityLabel(t.editInputs)
            }
        }
        .padding(.horizontal, 2)
    }

    private func chartSection(_ summary: CalcSummary) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(summary.chartTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Text(mask(summary.chartPeak))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.secondary)
                }
                GrowthChart(
                    points: summary.points,
                    primaryColor: Theme.accent,
                    secondaryColor: Theme.purple,
                    startYear: startYear,
                    fmt: fmt
                )
                HStack(spacing: 16) {
                    LegendItem(color: Theme.accent, label: summary.legendPrimary)
                    LegendItem(color: Theme.purple, label: summary.legendSecondary, dashed: true)
                    Spacer()
                }
                Text(t.chartHint)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.secondary)
            }
            .padding(16)
            .cardBackground()

            HStack(spacing: 10) {
                ForEach(Array(summary.stats.enumerated()), id: \.offset) { _, stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.secondary)
                            .lineLimit(1)
                        Text(mask(stat.value))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .cardBackground(radius: 18)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func scheduleSection(_ summary: CalcSummary) -> some View {
        LazyVStack(spacing: 10) {
            ForEach(summary.rows) { row in
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(row.dotColor)
                            .frame(width: 6, height: 6)
                            .shadow(color: row.dotColor, radius: 4)
                        Text(row.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.text)
                        Spacer()
                        Text(mask(row.right))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(row.rightColor)
                    }
                    HStack {
                        Text(mask(row.left2))
                        Spacer()
                        Text(mask(row.right2))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .cardBackground(radius: 20)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func adjustSection(_ summary: CalcSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(summary.fields) { spec in
                SliderRow(spec: spec, fmt: fmt) { editing = $0 }
            }
            Text(t.tapValueHint + "\n" + summary.note)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.secondary)
                .lineSpacing(3)
                .padding(.horizontal, 4)
        }
    }

    // MARK: Summaries

    private func savingsSummary() -> CalcSummary {
        let input = router.savings
        let result = Finance.savings(input, compounding: settings.compounding, depositAtStart: settings.depositAtStart)
        let fields = Fields.savings($router.savings, t: t)
        let multiplier = fmt.plain(result.multiplier, maxDigits: 1) + "×"

        let rows = result.timeline.dropFirst().map { year in
            ScheduleRow(
                id: year.year,
                title: t.yearRow(year.year, calendarYear: startYear + year.year),
                right: "+" + fmt.money(year.interest),
                rightColor: Theme.green,
                dotColor: Theme.green,
                left2: t.deposited(fmt.money(year.deposited)),
                right2: t.balance(fmt.money(year.balance))
            )
        }

        return CalcSummary(
            hero: fmt.money(result.futureValue, cents: true),
            heroSuffix: "",
            heroSub: t.heroSavingsSub(interest: fmt.money(result.interestEarned), years: input.years),
            planName: t.planSavings,
            theme: .sunset,
            cardValues: fields.map { CardValue(label: $0.shortLabel, value: fmt.value($0.kind, $0.get(), short: true)) },
            footer: [
                CardValue(label: t.footDeposits, value: mask(fmt.short(result.totalDeposited))),
                CardValue(label: t.footInterest, value: mask(fmt.short(result.interestEarned)))
            ],
            badge: mask(multiplier),
            chartTitle: t.chartSavingsTitle,
            chartPeak: fmt.short(result.futureValue),
            legendPrimary: t.legendBalance,
            legendSecondary: t.legendDeposits,
            points: result.timeline.map { ChartPoint(year: $0.year, primary: $0.balance, secondary: $0.deposited) },
            stats: [
                CardValue(label: t.footDeposits, value: fmt.short(result.totalDeposited)),
                CardValue(label: t.footInterest, value: fmt.short(result.interestEarned)),
                CardValue(label: t.statGrowth, value: multiplier)
            ],
            rows: Array(rows),
            note: t.savingsNote(compounding: settings.compounding, depositAtStart: settings.depositAtStart),
            fields: fields,
            shareText: t.shareSavings(
                fv: fmt.money(result.futureValue),
                years: input.years,
                monthly: fmt.money(input.monthly),
                rate: fmt.percent(input.annualRate, digits: 1...1),
                interest: fmt.money(result.interestEarned)
            )
        )
    }

    private func mortgageSummary() -> CalcSummary {
        let input = router.mortgage
        let result = Finance.mortgage(input)
        let fields = Fields.mortgage($router.mortgage, t: t)

        var cumulativeInterest = 0.0
        var points = [ChartPoint(year: 0, primary: result.loan, secondary: 0)]
        for year in result.schedule {
            cumulativeInterest += year.interest
            points.append(ChartPoint(year: year.year, primary: year.balance, secondary: cumulativeInterest))
        }

        let rows = result.schedule.map { year in
            ScheduleRow(
                id: year.year,
                title: t.yearRow(year.year, calendarYear: startYear + year.year),
                right: fmt.money(year.balance),
                rightColor: Theme.text,
                dotColor: Theme.accent,
                left2: t.principal(fmt.money(year.principal)),
                right2: t.interest(fmt.money(year.interest))
            )
        }

        return CalcSummary(
            hero: fmt.money(result.monthlyPayment, cents: true),
            heroSuffix: t.perMonth,
            heroSub: t.totalInterest(fmt.money(result.totalInterest)),
            planName: t.planMortgage,
            theme: .ocean,
            cardValues: fields.map { CardValue(label: $0.shortLabel, value: fmt.value($0.kind, $0.get(), short: true)) },
            footer: [
                CardValue(label: t.footLoan, value: mask(fmt.short(result.loan))),
                CardValue(label: t.footPayoff, value: String(startYear + input.years))
            ],
            badge: mask(fmt.short(result.monthlyPayment)),
            chartTitle: t.chartMortgageTitle,
            chartPeak: fmt.short(max(result.loan, result.totalInterest)),
            legendPrimary: t.legendLoanBalance,
            legendSecondary: t.legendInterestPaid,
            points: points,
            stats: [
                CardValue(label: t.footLoan, value: fmt.short(result.loan)),
                CardValue(label: t.statTotalInterest, value: fmt.short(result.totalInterest)),
                CardValue(label: t.statTotalCost, value: fmt.short(result.totalCost))
            ],
            rows: rows,
            note: t.mortgageNote,
            fields: fields,
            shareText: t.shareMortgage(
                payment: fmt.money(result.monthlyPayment),
                loan: fmt.money(result.loan),
                rate: fmt.percent(input.annualRate, digits: 1...2),
                years: input.years,
                interest: fmt.money(result.totalInterest)
            )
        )
    }

    // MARK: Helpers

    private func mask(_ text: String) -> String {
        router.amountsHidden ? "••••••" : text
    }

    private func defaultName() -> String {
        let kind = router.mode == .savings ? t.filterSavings : t.filterMortgage
        return kind + " · " + fmt.date(.now)
    }

    private func save(name: String) {
        let scenario = Scenario(
            name: name,
            kind: router.mode,
            theme: router.mode == .savings ? .sunset : .ocean,
            savings: router.savings,
            mortgage: router.mortgage
        )
        modelContext.insert(scenario)
        try? modelContext.save()

        withAnimation(.snappy) { showToast = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.snappy) { showToast = false }
        }
    }
}

struct SaveScenarioSheet: View {
    let theme: CardTheme
    let title: String
    let subtitle: String
    let defaultName: String
    let onSave: (String) -> Void

    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        let t = settings.strings
        VStack(alignment: .leading, spacing: 16) {
            Text(t.saveScenario)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.text)

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.gradient)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Theme.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(t.scenarioName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                TextField(defaultName, text: $name, prompt: Text(t.scenarioNamePlaceholder).foregroundColor(Theme.secondary))
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit(commit)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Theme.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(nameFocused ? Theme.accent : Theme.outline, lineWidth: 1.5)
                    )
            }

            HStack(spacing: 10) {
                Button { dismiss() } label: {
                    Text(t.cancel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Theme.divider, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                Button(action: commit) {
                    Text(t.save)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.onAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .padding(.top, 8)
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.tabBar)
        .presentationCornerRadius(30)
        .onAppear { nameFocused = true }
        .localizedEnvironment()
    }

    private func commit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(trimmed.isEmpty ? defaultName : trimmed)
        dismiss()
    }
}
