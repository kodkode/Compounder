# Compounder

A native iPhone app (SwiftUI) with two calculators — **compound interest** and **mortgage** —
in Hebrew (right-to-left) by default, with English as a second language. Amounts are in
Israeli new shekels (₪) by default.

Design canvas: https://claude.ai/artifact/Mn7aX91f2Bk3BCRKjq4QnF

## Screens

| Tab | What it does |
| --- | --- |
| בית · Home | Combined savings forecast, quick start, recent scenarios, rule-of-72 card |
| השוואה · Compare | Two scenarios side by side, winner banner, shared chart |
| מחשבון · Calculator | Plan card, growth chart, yearly breakdown / amortization schedule, sliders with tap-to-type |
| שמורים · Saved | Search, filter (all / savings / mortgage), long-press to delete |
| הגדרות · Settings | Hebrew ⇄ English, currency, monthly/yearly compounding, deposit timing, hide amounts |

## Run it on your iPhone

Requirements: Xcode 16 or newer, iOS 17 or newer on the phone.

1. Open `Compounder.xcodeproj` in Xcode.
2. Select the **Compounder** target → **Signing & Capabilities** → choose your **Team**
   (your paid developer account). If Xcode says the bundle ID is taken, change
   `com.kodkode.compounder.app` to something unique.
3. Plug in your iPhone (or pick it over Wi-Fi), select it as the run destination, press **Run** (⌘R).
   The first time, approve the developer on the phone: *Settings → General → VPN & Device Management*.

### TestFlight (optional)

*Product → Archive*, then *Distribute App → App Store Connect → Upload*. Once processed,
add yourself as an internal tester in App Store Connect and install from the TestFlight app.

## Project layout

```
Compounder.xcodeproj        Xcode project (synchronized folder — new files are picked up automatically)
Compounder/
  App/                      App entry point, navigation state
  Core/Finance.swift        Calculation engine (Foundation only)
  Localization/             Hebrew + English strings, number/currency formatting
  Models/                   SwiftData model for saved scenarios
  Settings/                 User preferences, RTL/locale environment
  Theme/                    Colors and card gradients
  Views/                    Screens and shared components
Package.swift               Exposes Core/ as a Swift package for unit tests
Tests/CompounderCoreTests/  Engine tests
```

## Tests

```sh
swift test
```

CI (`.github/workflows/ci.yml`) runs the tests and builds the app for the iOS Simulator on every push.
