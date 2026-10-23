import SwiftUI

struct CardValue {
    let label: String
    let value: String
}

/// The gradient "plan card" — inputs laid out like the digits on a bank card.
struct PlanCard: View {
    let theme: CardTheme
    let planName: String
    let values: [CardValue]
    let footer: [CardValue]
    let badge: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 2))
                    Text(verbatim: "COMPOUNDER")
                        .font(.system(size: 17, weight: .heavy))
                        .tracking(1.2)
                }
                .environment(\.layoutDirection, .leftToRight)
                .accessibilityHidden(true)
                Spacer(minLength: 8)
                Text(planName)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Spacer(minLength: 12)

            HStack(alignment: .top, spacing: 6) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.value)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                        Text(item.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.88))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                }
            }

            Spacer(minLength: 12)

            HStack(alignment: .bottom) {
                HStack(spacing: 22) {
                    ForEach(Array(footer.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.88))
                            Text(item.value)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                Spacer(minLength: 8)
                Text(badge)
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(hex: 0x140C28, opacity: 0.28), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .environment(\.layoutDirection, .leftToRight)
            }
        }
        .foregroundStyle(.white)
        .padding(EdgeInsets(top: 22, leading: 22, bottom: 20, trailing: 22))
        .frame(maxWidth: .infinity)
        .frame(height: 212)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(theme.gradient)
                .overlay(
                    RadialGradient(colors: [theme.sheen, .clear], center: .topLeading, startRadius: 0, endRadius: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.38), radius: 22, y: 16)
        }
        .background { blobs }
    }

    private var blobs: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(LinearGradient(colors: theme.blobs.top, startPoint: .top, endPoint: .bottom))
                .frame(width: 120, height: 180)
                .rotationEffect(.degrees(18))
                .offset(x: 58, y: -26)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(LinearGradient(colors: theme.blobs.bottom, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 150, height: 120)
                .rotationEffect(.degrees(-12))
                .offset(x: -46, y: 34)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityHidden(true)
    }
}
