import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            Group {
                switch router.tab {
                case .home: HomeView()
                case .compare: CompareView()
                case .calculator: CalculatorView()
                case .saved: SavedView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabBar: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let t = settings.strings
        HStack(alignment: .top, spacing: 0) {
            item(.home, icon: "house", label: t.tabHome)
            item(.compare, icon: "chart.bar.xaxis", label: t.tabCompare)
            centerItem(label: t.tabCalculator)
            item(.saved, icon: "bookmark", label: t.tabSaved)
            item(.settings, icon: "gearshape", label: t.tabSettings)
        }
        .padding(.horizontal, 6)
        .padding(.top, 12)
        .frame(height: 66, alignment: .top)
        .background(alignment: .top) {
            UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30, style: .continuous)
                .fill(Theme.tabBar)
                .shadow(color: .black.opacity(0.25), radius: 15, y: -6)
                .ignoresSafeArea(edges: .bottom)
        }
        .sensoryFeedback(.selection, trigger: router.tab)
    }

    private func item(_ tab: AppTab, icon: String, label: String) -> some View {
        let isOn = router.tab == tab
        return Button {
            router.tab = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(label)
                    .font(.system(size: 11, weight: isOn ? .semibold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isOn ? Theme.text : Theme.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .overlay(alignment: .top) {
                if isOn {
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: 24, height: 3)
                        .shadow(color: Theme.accent, radius: 6)
                        .offset(y: -14)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func centerItem(label: String) -> some View {
        let isOn = router.tab == .calculator
        return Button {
            router.tab = .calculator
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedHexagon(color: Theme.accent)
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 62, height: 62)
                .shadow(color: Theme.accent.opacity(isOn ? 0.6 : 0.35), radius: isOn ? 16 : 10, y: 6)
                Text(label)
                    .font(.system(size: 11, weight: isOn ? .semibold : .medium))
                    .foregroundStyle(isOn ? Theme.text : Theme.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .offset(y: -32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
