import SwiftUI

enum FieldKind {
    case money, percent0, percent1, percent2, years
}

/// One editable input (slider + tap-to-type), bound through closures so the
/// same row works for the calculator and for either compare scenario.
struct FieldSpec: Identifiable {
    let id: String
    let shortLabel: String
    let label: String
    let range: ClosedRange<Double>
    let step: Double
    let kind: FieldKind
    let get: () -> Double
    let set: (Double) -> Void

    /// Raw number for the type-in field (no grouping, no symbols).
    var editText: String {
        let value = get()
        if kind == .years { return String(Int(value)) }
        return value.formatted(.number.precision(.fractionLength(0...2)).grouping(.never).locale(Locale(identifier: "en_US_POSIX")))
    }
}

enum Fields {
    static func savings(_ input: Binding<SavingsInput>, t: Strings) -> [FieldSpec] {
        [
            FieldSpec(id: "initial", shortLabel: t.fieldInitialShort, label: t.fieldInitial,
                      range: 0...1_000_000, step: 5_000, kind: .money,
                      get: { input.wrappedValue.initial }, set: { input.wrappedValue.initial = $0 }),
            FieldSpec(id: "monthly", shortLabel: t.fieldMonthlyShort, label: t.fieldMonthly,
                      range: 0...20_000, step: 100, kind: .money,
                      get: { input.wrappedValue.monthly }, set: { input.wrappedValue.monthly = $0 }),
            FieldSpec(id: "rate", shortLabel: t.fieldReturnShort, label: t.fieldReturn,
                      range: 0...15, step: 0.1, kind: .percent1,
                      get: { input.wrappedValue.annualRate }, set: { input.wrappedValue.annualRate = $0 }),
            FieldSpec(id: "years", shortLabel: t.fieldYearsShort, label: t.fieldSavingsYears,
                      range: 1...50, step: 1, kind: .years,
                      get: { Double(input.wrappedValue.years) }, set: { input.wrappedValue.years = Int($0.rounded()) })
        ]
    }

    static func mortgage(_ input: Binding<MortgageInput>, t: Strings) -> [FieldSpec] {
        [
            FieldSpec(id: "price", shortLabel: t.fieldPriceShort, label: t.fieldPrice,
                      range: 300_000...10_000_000, step: 50_000, kind: .money,
                      get: { input.wrappedValue.price }, set: { input.wrappedValue.price = $0 }),
            FieldSpec(id: "down", shortLabel: t.fieldDownShort, label: t.fieldDown,
                      range: 0...75, step: 1, kind: .percent0,
                      get: { input.wrappedValue.downPercent }, set: { input.wrappedValue.downPercent = $0 }),
            FieldSpec(id: "rate", shortLabel: t.fieldRateShort, label: t.fieldRate,
                      range: 0...10, step: 0.05, kind: .percent2,
                      get: { input.wrappedValue.annualRate }, set: { input.wrappedValue.annualRate = $0 }),
            FieldSpec(id: "years", shortLabel: t.fieldYearsShort, label: t.fieldTerm,
                      range: 4...30, step: 1, kind: .years,
                      get: { Double(input.wrappedValue.years) }, set: { input.wrappedValue.years = Int($0.rounded()) })
        ]
    }
}

struct SliderRow: View {
    let spec: FieldSpec
    let fmt: Fmt
    var tint: Color = Theme.accent
    let onEdit: (FieldSpec) -> Void

    var body: some View {
        let value = spec.get()
        let text = fmt.value(spec.kind, value, short: false)
        VStack(spacing: 2) {
            HStack(alignment: .center, spacing: 8) {
                Text(spec.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                Spacer(minLength: 0)
                Button { onEdit(spec) } label: {
                    HStack(spacing: 5) {
                        Text(text)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.text)
                            .contentTransition(.numericText())
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.secondary)
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(spec.label)
                .accessibilityValue(text)
            }
            Slider(
                value: Binding(
                    get: { min(max(spec.get(), spec.range.lowerBound), spec.range.upperBound) },
                    set: { spec.set($0) }
                ),
                in: spec.range,
                step: spec.step
            )
            .tint(tint)
            .accessibilityLabel(spec.label)
            .accessibilityValue(text)
            .sensoryFeedback(.selection, trigger: value)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
        .cardBackground(radius: 20)
        .animation(.snappy(duration: 0.2), value: text)
    }
}

/// Type-in alert for an exact value. Attach once per screen.
struct FieldEditor: ViewModifier {
    @Binding var editing: FieldSpec?
    @EnvironmentObject private var settings: AppSettings
    @State private var text = ""

    func body(content: Content) -> some View {
        let t = settings.strings
        let fmt = settings.fmt
        let current = editing
        return content
            .alert(
                current?.label ?? "",
                isPresented: Binding(get: { editing != nil }, set: { if !$0 { editing = nil } })
            ) {
                TextField(current?.label ?? "", text: $text)
                    .keyboardType(current?.kind == .years ? .numberPad : .decimalPad)
                Button(t.cancel, role: .cancel) {}
                Button(t.done) { apply(current) }
            } message: {
                if let spec = current {
                    Text(t.allowedRange(
                        fmt.value(spec.kind, spec.range.lowerBound, short: false),
                        fmt.value(spec.kind, spec.range.upperBound, short: false)
                    ))
                }
            }
            .onChange(of: editing?.id) { _, _ in
                if let spec = editing { text = spec.editText }
            }
    }

    private func apply(_ spec: FieldSpec?) {
        guard let spec else { return }
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Double(cleaned), number.isFinite else { return }
        spec.set(min(max(number, spec.range.lowerBound), spec.range.upperBound))
    }
}

extension View {
    func fieldEditor(_ editing: Binding<FieldSpec?>) -> some View {
        modifier(FieldEditor(editing: editing))
    }
}
