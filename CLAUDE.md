# Compounder — project memory

Read this first. These are standing decisions from the owner — do not ask about them again.

## Owner setup (settled — never re-ask)
- Target platform: **native iPhone app (SwiftUI)**. Not a web app / PWA.
- The owner **has a Mac with Xcode** and a **paid Apple Developer Program membership ($99/yr)**.
  So: device installs don't expire, TestFlight and App Store distribution are available.
- Bundle ID: `com.kodkode.compounder.app` (`com.kodkode.Compounder` is taken on Apple's side).
  Never change it after the first App Store Connect upload.
- Cloud sessions run on Linux and cannot build iOS. Verify Swift changes through the
  GitHub Actions workflow (`.github/workflows/ci.yml`, macOS runner) instead of asking
  the owner to build.

## Product decisions
- Two calculators: **compound interest (savings)** and **mortgage**.
- **Hebrew is the default language with full RTL**; English is the second language,
  switchable in-app (Settings). Every user-facing string must exist in both languages
  (`Compounder/Localization/Strings.swift`).
- Default currency: **Israeli new shekel (₪, ILS)**. USD/EUR are optional extras.
- Visual direction: concept **"B · Card"** — dark navy-violet UI, gradient "plan card",
  orange accent, hexagon center tab button.
  Design canvas: https://claude.ai/artifact/Mn7aX91f2Bk3BCRKjq4QnF
- Real tabs: Home, Compare, Calculator (center hexagon), Saved, Settings.
- Mortgage scope for now: fixed monthly payment (Spitzer), principal + interest only.
  Taxes, insurance, CPI linkage and mortgage tracks are explicitly **out of scope for now**
  (owner said "maybe later").
- Charts keep time flowing left-to-right even in Hebrew (common in Israeli finance apps).

## Code layout
- `Compounder.xcodeproj` — Xcode 16+ project using a synchronized folder (`Compounder/`);
  new files inside `Compounder/` are picked up automatically, no project edits needed.
- `Compounder/Core/` — pure-Foundation calculation engine. Also exposed as the
  `CompounderCore` Swift package (root `Package.swift`) so `swift test` runs its tests.
  Keep it free of SwiftUI/UIKit imports.
- `Tests/CompounderCoreTests/` — unit tests for the engine.
- Minimum iOS: 17.0 (SwiftData, Swift Charts selection, Observation-era APIs).
