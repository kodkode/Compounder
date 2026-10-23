import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings

    private var t: Strings { settings.strings }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ScreenScroll(spacing: 22) {
            LargeTitle(title: t.settingsTitle) { EmptyView() }

            group(t.languageTitle, footer: t.languageNote) {
                PillSegment(selection: $settings.language, options: AppLanguage.allCases.map {
                    SegmentOption(value: $0, label: $0.nativeName)
                })
            }

            group(t.currencyTitle) {
                VStack(spacing: 0) {
                    ForEach(Array(AppCurrency.allCases.enumerated()), id: \.element) { index, currency in
                        currencyRow(currency)
                        if index < AppCurrency.allCases.count - 1 {
                            Rectangle().fill(Theme.divider).frame(height: 1).padding(.leading, 64)
                        }
                    }
                }
                .cardBackground(radius: 22)
            }

            group(t.calculationsTitle) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text(t.compoundingTitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.text)
                        Spacer(minLength: 0)
                        PillSegment(selection: $settings.compounding, options: [
                            SegmentOption(value: .monthly, label: t.monthly),
                            SegmentOption(value: .yearly, label: t.yearly)
                        ], height: 34, fontSize: 13)
                        .frame(width: 180)
                    }
                    .padding(.vertical, 10)
                    Rectangle().fill(Theme.divider).frame(height: 1)
                    toggleRow(t.depositAtStart, hint: t.depositAtStartHint, isOn: $settings.depositAtStart)
                    Rectangle().fill(Theme.divider).frame(height: 1)
                    toggleRow(t.hideOnLaunch, hint: t.hideOnLaunchHint, isOn: $settings.hideAmountsOnLaunch)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .cardBackground(radius: 22)
            }

            group(t.aboutTitle, footer: t.disclaimer) {
                HStack {
                    Text(t.version)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Text(appVersion)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                        .environment(\.layoutDirection, .leftToRight)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 56)
                .cardBackground(radius: 22)
            }
        }
    }

    private func group<Content: View>(_ title: String, footer: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.secondary)
                .padding(.horizontal, 4)
                .accessibilityAddTraits(.isHeader)
            content()
            if let footer {
                Text(footer)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                    .lineSpacing(3)
                    .padding(.horizontal, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func currencyRow(_ currency: AppCurrency) -> some View {
        let isOn = settings.currency == currency
        return Button {
            settings.currency = currency
        } label: {
            HStack(spacing: 12) {
                Text(currency.symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .frame(width: 36, height: 36)
                    .background(Theme.divider, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(t.currencyName(currency))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.text)
                Spacer(minLength: 0)
                ZStack {
                    Circle()
                        .strokeBorder(isOn ? .clear : Theme.outline, lineWidth: 2)
                        .background(Circle().fill(isOn ? Theme.accent : .clear))
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(Theme.onAccent)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isOn)
    }

    private func toggleRow(_ title: String, hint: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.text)
                Text(hint)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.secondary)
            }
        }
        .tint(Theme.accent)
        .padding(.vertical, 10)
    }
}
