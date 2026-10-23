import SwiftUI

/// A saved scenario in a list (Home and Saved).
struct ScenarioRow: View {
    let scenario: Scenario
    var showDate = false
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let summary = scenario.summary(settings: settings)
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(scenario.theme.gradient)
                .frame(width: 48, height: showDate ? 60 : 48)
                .overlay(
                    Image(systemName: scenario.kind == .mortgage ? "house" : "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .shadow(color: .black.opacity(0.25), radius: 8, y: 6)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(scenario.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(summary.value)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                }
                HStack(spacing: 8) {
                    Text(summary.meta)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(summary.unit)
                        .lineLimit(1)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.secondary)
                if showDate {
                    Text(settings.strings.savedOn(settings.fmt.date(scenario.createdAt)))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                }
            }

            Image(systemName: "chevron.forward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.secondary)
        }
        .padding(12)
        .cardBackground(radius: 20)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
