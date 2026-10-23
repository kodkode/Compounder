import SwiftUI
import SwiftData

struct SavedView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Scenario.createdAt, order: .reverse) private var scenarios: [Scenario]

    @State private var query = ""
    @State private var filter: CalcMode?

    private var t: Strings { settings.strings }

    private var visible: [Scenario] {
        let needle = query.trimmingCharacters(in: .whitespaces)
        return scenarios.filter { scenario in
            (filter == nil || scenario.kind == filter)
                && (needle.isEmpty || scenario.name.localizedCaseInsensitiveContains(needle))
        }
    }

    var body: some View {
        ScreenScroll(spacing: 16) {
            LargeTitle(title: t.savedTitle) {
                Button { router.startNew(router.mode) } label: {
                    IconButtonLabel(systemName: "plus")
                }
                .accessibilityLabel(t.newScenario)
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.secondary)
                TextField(t.searchPlaceholder, text: $query, prompt: Text(t.searchPlaceholder).foregroundColor(Theme.secondary))
                    .foregroundStyle(Theme.text)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.secondary)
                    }
                    .accessibilityLabel(t.cancel)
                }
            }
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .frame(height: 50)
            .cardBackground(radius: 18)

            HStack(spacing: 8) {
                filterChip(nil, label: t.filterAll)
                filterChip(.savings, label: t.filterSavings)
                filterChip(.mortgage, label: t.filterMortgage)
                Spacer(minLength: 0)
            }

            if scenarios.isEmpty {
                emptyState(icon: "bookmark", title: t.emptyTitle, message: t.emptyBody)
            } else if visible.isEmpty {
                emptyState(icon: "magnifyingglass", title: t.noMatchTitle, message: t.noMatchBody)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(visible) { scenario in
                        Button { router.open(scenario) } label: {
                            ScenarioRow(scenario: scenario, showDate: true)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation { modelContext.delete(scenario) }
                            } label: {
                                Label(t.delete, systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    private func filterChip(_ value: CalcMode?, label: String) -> some View {
        let isOn = filter == value
        let count = scenarios.filter { value == nil || $0.kind == value }.count
        return Button {
            withAnimation(.snappy) { filter = value }
        } label: {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                Text(String(count))
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(isOn ? Theme.onAccent.opacity(0.16) : Theme.divider, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .foregroundStyle(isOn ? Theme.onAccent : Theme.textSoft)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(isOn ? Theme.accent : Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isOn)
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(Theme.secondary)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.text)
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .cardBackground(radius: 22)
    }
}
