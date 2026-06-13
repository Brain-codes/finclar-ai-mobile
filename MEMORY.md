# Finclar AI (mobile) — Project Memory

A running, dated log of project state and decisions — the "where are we right now"
companion to the deep reference docs. **This file is not the architecture spec.**

**Where the detailed knowledge already lives (read these first, don't duplicate them here):**
- `CLAUDE.md` — full development spec: architecture, design-system rules, API rule,
  state management, screen decomposition, navigation, models, dark mode, biometric,
  push, Figma workflow. The source of truth for *how* to build in this codebase.
- `docs/API.md` — single source of truth for backend endpoints/schemas. Mirrored by
  `lib/core/api/api_endpoints.dart`.
- `graphify-out/` — generated knowledge graph of the codebase (graph.json,
  manifest.json, analysis). Useful for "where is X / what calls Y" questions, but
  **known to be incomplete** — verify against current code before relying on it.

Keep this file as a concise changelog + current-state + open-threads note. Add a
dated entry whenever meaningful work happens. Convention/architecture facts belong
in `CLAUDE.md`, not here.

---

## What this project is

Finclar AI — a full AI-powered personal-finance mobile app (Flutter), not a small
project. The companion marketing site is a separate repo at
`/Users/Efe/Projects/Web/finclar-ai-web`.

**Stack:** Flutter · Riverpod (`flutter_riverpod` + `riverpod_annotation`) ·
go_router · Dio (via `ApiClient`) · Drift + sqlite3 (local db) ·
flutter_secure_storage + shared_preferences · Firebase (core + messaging) ·
freezed/json_serializable models · fl_chart · google_mlkit_text_recognition (OCR) ·
local_auth (biometric) · flutter_svg · remixicon · toastification ·
flutter_form_builder.

**Architecture:** feature-first + lightweight layered. `lib/` splits into
`app/`, `core/`, `shared/`, `features/`, `main.dart`. ~200 Dart files.
(Full folder rules in `CLAUDE.md §1`.)

**Backend:** `https://finclar-ai.onrender.com/api/v1` (Swagger at `/docs`).

## Feature areas & rough status

Derived from `CLAUDE.md` feature list + git history (as of 2026-06-12). Treat
status as approximate — confirm against the code/branch before building on it.

| Feature        | Scope                                                        | Status (approx) |
| -------------- | ----------------------------------------------------------- | --------------- |
| `splash`       | 3 onboarding splash screens                                 | Built           |
| `auth`         | sign_up, verify (email & phone), login, forgot_passcode     | Built; logout + loading/error states recently added |
| `home`         | dashboard, income_setup (AI/manual), ai_setup, recent expenses | Built; income setup modal + provider in place |
| `expenses`     | list, add_manual, add_ocr (scan receipt), bank_integration  | Built; OCR scan + scanned-expense editing + bank linking landed |
| `budget`       | list, create_manual, allocation, summary                    | Built (recent) |
| `group`        | list, create, detail, add_friend, group chat (bubbles, input bar, media preview) | In progress — chat UI being fleshed out |
| `subscription` | plans, upgrade, active subscription + cancellation sheets   | UI built |
| `gamification` | insight slides, "wrapped" savings/insights screens          | In progress     |
| `settings`     | main settings, account/contact tiles, edit username, delete-account sheet | Built |

## Open threads / known issues

- **Username availability race (from `TODOs.txt`):** on sign-up, typing quickly
  causes the inline "username is taken" error to conflict with the suffix-icon
  check-mark (showing "available"). The async validation result lags behind fast
  input — debounce/cancel stale checks so the error text and the icon always agree.

## Gotchas / environment notes

- **Never hardcode** colors, type, spacing, radii, icons, strings, or URLs — use the
  `App*` token classes and `ApiEndpoints` (enforced in `CLAUDE.md §2/§5`).
- **Dark mode is required** for everything, with no Figma reference — use design
  initiative and the `dark*` tokens in `AppColors`. Test both modes before "done".
- All HTTP goes through `ApiClient`; all responses are `ApiResponse<T>`. Fix backend
  shape mismatches in `ApiResponse.fromJson`, not at call sites.
- `default_currency` comes back in the auth response — pass it to
  `AppConfigNotifier.applyCurrency()` immediately after login/register.
- `graphify-out/` is stale/partial (generated 2026-05-29) — useful as a map, not as
  ground truth.

---

## Dated log

### 2026-06-12 — MEMORY.md created
First memory file for the mobile app. State snapshot above was reconstructed from
`CLAUDE.md`, `pubspec.yaml`, `TODOs.txt`, `graphify-out/`, and the recent git log
(latest commits: logout w/ loading+error handling, gamification slides, OCR expense
scanning + bank linking, group chat UI, subscription management UI, budget
management). No code changes — documentation only.
