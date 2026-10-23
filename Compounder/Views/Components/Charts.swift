import SwiftUI
import Charts

struct ChartPoint: Identifiable {
    let year: Int
    let primary: Double
    let secondary: Double
    var id: Int { year }
}

/// Area + line for the main series, dashed line for the comparison series.
/// Time always runs left to right, also in Hebrew.
struct GrowthChart: View {
    let points: [ChartPoint]
    let primaryColor: Color
    let secondaryColor: Color
    var fillPrimary = true
    var secondaryDashed = true
    let startYear: Int
    let fmt: Fmt

    @State private var selectedYear: Int?

    private var selectedPoint: ChartPoint? {
        guard let selectedYear else { return nil }
        return points.first { $0.year == selectedYear }
    }

    var body: some View {
        Chart {
            ForEach(points) { point in
                if fillPrimary {
                    AreaMark(
                        x: .value("Year", point.year),
                        y: .value("Amount", point.primary)
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [primaryColor.opacity(0.4), primaryColor.opacity(0)], startPoint: .top, endPoint: .bottom)
                    )
                    .interpolationMethod(.monotone)
                }
                LineMark(
                    x: .value("Year", point.year),
                    y: .value("Amount", point.primary),
                    series: .value("Series", "primary")
                )
                .foregroundStyle(primaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Year", point.year),
                    y: .value("Amount", point.secondary),
                    series: .value("Series", "secondary")
                )
                .foregroundStyle(secondaryColor)
                .lineStyle(StrokeStyle(lineWidth: secondaryDashed ? 2 : 3, lineCap: .round, dash: secondaryDashed ? [5, 5] : []))
                .interpolationMethod(.monotone)
            }

            if let point = selectedPoint {
                RuleMark(x: .value("Year", point.year))
                    .foregroundStyle(Theme.secondary.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top, spacing: 6, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        VStack(spacing: 2) {
                            Text(String(startYear + point.year))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.secondary)
                            Text(fmt.short(point.primary))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(primaryColor)
                            Text(fmt.short(point.secondary))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(secondaryColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.raised, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                PointMark(
                    x: .value("Year", point.year),
                    y: .value("Amount", point.primary)
                )
                .foregroundStyle(.white)
                .symbolSize(50)
            }
        }
        .chartXSelection(value: $selectedYear)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisValueLabel {
                    if let year = value.as(Int.self) {
                        Text(String(startYear + year))
                            .foregroundStyle(Theme.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                    .foregroundStyle(Theme.divider)
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(fmt.short(amount))
                            .foregroundStyle(Theme.secondary)
                    }
                }
            }
        }
        .frame(height: 190)
        .environment(\.layoutDirection, .leftToRight)
        .sensoryFeedback(.selection, trigger: selectedYear)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    var dashed = false

    var body: some View {
        HStack(spacing: 6) {
            if dashed {
                Rectangle()
                    .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                    .frame(width: 14, height: 0.5)
            } else {
                Capsule().fill(color).frame(width: 14, height: 3)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textSoft)
        }
    }
}
