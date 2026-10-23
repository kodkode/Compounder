import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Scenario.createdAt, order: .reverse) private var scenarios: [Scenario]
    @State private var ruleRate: Double = 6

    private var t: Strings { settings.strings }
    private var fmt: Fmt { settings.fmt }

    var body: some View {
        ScreenScroll(spacing: 20) {
            LargeTitle(
                title: t.greeting(hour: Calendar.current.component(.hour, from: .now)),
                subtitle: t.homeSubtitle
            ) {
                Button { router.tab = .saved } label: {
                    IconButtonLabel(systemName: "magnifyingglass")
                }
                .accessibilityLabel(t.searchSaved)
            }

            forecastCard

            VStack(spacing: 12) {
                SectionTitle(text: t.newCalculation)
                HStack(spacing: 12) {
                    quickStart(
                        title: t.savings,
                        subtitle: t.quickSavingsSubtitle,
                        icon: "chart.line.uptrend.xyaxis",
                        theme: .sunset
                    ) { router.startNew(.savings) }
                    quickStart(
                        title: t.mortgage,
                        subtitle: t.quickMortgageSubtitle,
                        icon: "house",
                        theme: .ocean
                    ) { router.startNew(.mortgage) }
                }
            }

            VStack(spacing: 10) {
                HStack {
                    SectionTitle(text: t.recentTitle)
                    if !scenarios.isEmpty {
                        Button(t.seeAll) { router.tab = .saved }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .frame(minHeight: 44)
                    }
                }
                if scenarios.isEmpty {
                    Text(t.noScenariosYet)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .cardBackground(radius: 20)
                } else {
                    ForEach(scenarios.prefix(3)) { scenario in
                        Button { router.open(scenario) } label: {
                            ScenarioRow(scenario: scenario)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            ruleOf72Card
        }
    }

    // MARK: Forecast

    private var forecastCard: some View {
        let plans = scenarios.filter { $0.kind == .savings }
        let results = plans.map {
            Finance.savings($0.savingsInput, compounding: settings.compounding, depositAtStart: settings.depositAtStart)
        }
        let total = results.reduce(0) { $0 + $1.futureValue }
        let deposits = results.reduce(0) { $0 + $1.totalDeposited }
        let depositShare = total > 0 ? min(1, deposits / total) : 0

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(t.forecastTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                Spacer()
                if !plans.isEmpty {
                    Text(t.forecastPlans(plans.count))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.green.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }

            if plans.isEmpty {
                Text(t.forecastEmpty)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(router.amountsHidden ? "••••••" : fmt.money(total))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                GeometryReader { proxy in
                    HStack(spacing: 6) {
                        Capsule().fill(Theme.purple)
                            .frame(width: max(8, (proxy.size.width - 6) * depositShare))
                        Capsule().fill(Theme.accent)
                    }
                }
                .frame(height: 8)
                .environment(\.layoutDirection, .leftToRight)

                HStack {
                    LegendDot(color: Theme.purple, text: t.footDeposits + " " + mask(fmt.short(deposits)))
                    Spacer()
                    LegendDot(color: Theme.accent, text: t.footInterest + " " + mask(fmt.short(max(0, total - deposits))))
                }
            }
        }
        .padding(20)
        .background {
            ZStack(alignment: .topLeading) {
                Theme.card
                RadialGradient(colors: [Theme.accent.opacity(0.35), .clear], center: .topLeading, startRadius: 0, endRadius: 180)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    private func quickStart(title: String, subtitle: String, icon: String, theme: CardTheme, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(theme.gradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .shadow(color: theme.colors[2].opacity(0.35), radius: 9, y: 8)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.secondary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .cardBackground()
        }
        .buttonStyle(.plain)
    }

    // MARK: Rule of 72

    private var ruleOf72Card: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xC4B5FD))
                    .frame(width: 36, height: 36)
                    .background(Theme.purple.opacity(0.16), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(t.rule72Title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.text)
            }
            Text(t.rule72Body)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach([4.0, 6.0, 8.0, 10.0], id: \.self) { rate in
                    let isOn = rate == ruleRate
                    Button {
                        withAnimation(.snappy) { ruleRate = rate }
                    } label: {
                        Text(fmt.percent(rate, digits: 0...0))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isOn ? Theme.onAccent : Theme.textSoft)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(isOn ? Theme.accent : Theme.divider, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(fmt.plain(Finance.ruleOf72(annualRate: ruleRate), maxDigits: 1))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText())
                Text(t.yearsToDouble)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondary)
            }
        }
        .padding(18)
        .cardBackground()
    }

    private func mask(_ text: String) -> String {
        router.amountsHidden ? "••••" : text
    }
}

struct LegendDot: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSoft)
        }
    }
}
