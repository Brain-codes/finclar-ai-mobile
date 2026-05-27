<p align="center">
  <img src="assets/logo/logo.png" width="100" alt="Finclar AI Logo" />
</p>

<h1 align="center">Finclar AI</h1>

<p align="center">
  <strong>Smart personal finance, powered by AI.</strong><br/>
  Track expenses, manage budgets, split costs with groups — all in one place.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/License-Private-red" />
</p>

---

## Screenshots

> Add app screenshots here once available — home dashboard, expense log, budget overview, group screen.

---

## What It Does

| Feature | Description |
|---|---|
| **Expense Tracking** | Log expenses manually or by scanning receipts with OCR. Every transaction is categorized automatically. |
| **AI-Powered Insights** | Set up your income profile with AI assistance. Get personalized budget suggestions and spending analysis. |
| **Budget Management** | Create and monitor budgets by category. Visual breakdowns show exactly where your money is going. |
| **Group Finance** | Create groups with friends or family to split expenses, track shared budgets, and chat in real time. |
| **Bank Integration** | Connect your bank account to auto-import transactions (no manual entry required). |
| **Subscription Management** | Upgrade, manage, or cancel your Finclar subscription directly in the app. |
| **Biometric Login** | Secure passcode login with Face ID / fingerprint support for returning users. |
| **Push Notifications** | Real-time alerts for transactions, budget limits, group activity, and AI insights. |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Navigation | go_router |
| Networking | Dio |
| Local Database | Drift (SQLite) |
| Secure Storage | flutter_secure_storage |
| Push Notifications | Firebase Cloud Messaging |
| Biometric Auth | local_auth |
| Charts | fl_chart |
| Forms | flutter_form_builder |
| Icons | Remixicon (via `AppIcons` wrapper) |
| SVGs | flutter_svg (via `AppSvgImage` wrapper) |
| Logging | logger (via `Log` wrapper) |
| Formatting | intl |

---

## Project Structure

```
lib/
├── app/              # Router and root MaterialApp
├── core/             # API client, theme, services, constants, utils
├── shared/           # Global reusable widgets, icons, SVG wrappers
└── features/
    ├── splash/       # Onboarding
    ├── auth/         # Sign up, login, verify, forgot passcode
    ├── home/         # Dashboard, income setup, AI setup
    ├── expenses/     # Expense list, manual entry, OCR scanning, bank sync
    ├── budget/       # Budget list and creation
    ├── group/        # Groups, chat, friends
    ├── settings/     # App settings
    └── subscription/ # Plans and upgrade flow
```

---

## Design System

The app ships a strict design system. Nothing is hardcoded.

| Token | Source |
|---|---|
| Colors | `AppColors` |
| Typography | `AppTypography` — Bricolage Grotesque (display) + Geist (body) |
| Spacing | `AppSpacing` |
| Border Radii | `AppRadius` |
| Icons | `AppIcons` |
| SVGs | `AppSvg` + `AppSvgImage` |
| Strings | `AppStrings` |

Both light and dark modes are fully supported.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- CocoaPods (iOS)
- Firebase project with `google-services.json` / `GoogleService-Info.plist`

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Native Assets (icon + splash)

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Architecture Notes

- **Feature-first** folder structure — each feature is self-contained with its own data, domain, presentation, and providers layers.
- **Riverpod** for all state — no `setState` for non-local state.
- **go_router** for all navigation — no `Navigator.push` anywhere.
- **ApiClient** wraps all HTTP calls — Dio is never used directly in feature code.
- **No raw print statements** — all logging goes through the `Log` service.

---

## License

Private. All rights reserved.
