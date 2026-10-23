import SwiftUI

/// Standard scrolling screen: padded column that clears the floating tab bar.
struct ScreenScroll<Content: View>: View {
    var spacing: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: spacing) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
    }
}

/// Centered title with optional buttons on each side.
struct ScreenHeader<Leading: View, Trailing: View>: View {
    let title: String
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textSoft)
                .accessibilityAddTraits(.isHeader)
            HStack {
                leading
                Spacer()
                trailing
            }
        }
        .frame(height: 48)
    }
}

/// Large leading title, used by Home, Saved and Settings.
struct LargeTitle<Trailing: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .frame(minHeight: 48)
    }
}

struct IconButtonLabel: View {
    let systemName: String
    var circle = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(Theme.icon)
            .frame(width: 46, height: 46)
            .background(
                Theme.iconButton,
                in: circle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            )
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Theme.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Segmented pill control

struct SegmentOption<Value: Hashable>: Identifiable {
    let value: Value
    let label: String
    var id: Value { value }
}

struct PillSegment<Value: Hashable>: View {
    @Binding var selection: Value
    let options: [SegmentOption<Value>]
    var height: CGFloat = 46
    var fontSize: CGFloat = 15

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options) { option in
                let isOn = option.value == selection
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selection = option.value }
                } label: {
                    Text(option.label)
                        .font(.system(size: fontSize, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(isOn ? Theme.text : Theme.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .background {
                            if isOn {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Theme.raised)
                                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                                    .matchedGeometryEffect(id: "pill", in: namespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .padding(6)
        .background(Theme.track, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Hexagon (center tab button)

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        for index in 0..<6 {
            let angle = (Double(index) * 60 - 90) * .pi / 180
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

/// Hexagon with softly rounded corners: filled, then stroked in the same color.
struct RoundedHexagon: View {
    var color: Color

    var body: some View {
        InsetHexagon(amount: 4)
            .fill(color)
            .overlay(
                InsetHexagon(amount: 4)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineJoin: .round))
            )
    }
}

struct InsetHexagon: Shape {
    var amount: CGFloat

    func path(in rect: CGRect) -> Path {
        Hexagon().path(in: rect.insetBy(dx: amount, dy: amount))
    }
}

// MARK: - Toast

struct ToastView: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(hex: 0x16A34A))
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.onAccent)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Theme.text, in: Capsule())
        .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Card-styled container

extension View {
    func cardBackground(radius: CGFloat = 24) -> some View {
        background(Theme.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
