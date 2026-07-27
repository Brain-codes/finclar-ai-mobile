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
| `budget`       | list, create_manual, allocation, summary                    | Built + **wired to live `/budgets` API** (2026-06-19) |
| `group`        | list, create, detail, friends, group chat, savings, friend invites | **Fully wired to live API** (2026-07-06) — friends + groups + members + savings + chat |
| `subscription` | plans, upgrade, active subscription + cancellation sheets   | **Wired to live `/subscriptions` API** (2026-07-20); Paystack checkout untested against a real key |
| `gamification` | insight slides, "wrapped" savings/insights screens          | In progress     |
| `settings`     | main settings, account/contact tiles, edit username, delete-account sheet | Built |

## Open threads / known issues

- **Apple sign-in is blocked on Apple Developer account access — Google is fully live.**
  Google sign-in works on **both iOS and Android** now (config done 2026-06-19). Apple is
  fully coded but the **button is hidden** behind `kAppleSignInEnabled = false` in
  `sign_up_screen.dart`. Two things remain before flipping it on: (1) enable the **Apple**
  provider in the Firebase console (Authentication → Sign-in method → Apple → Enable; leave
  Services-ID/key blank for native iOS); (2) register the **"Sign in with Apple" capability**
  on Apple's developer portal for App ID `com.finclar.finclarAi` (easiest via Xcode →
  Runner → Signing & Capabilities, which also regenerates the provisioning profile).
  **Account constraint discovered (confirmed by a build failure):** the team currently in
  the Xcode project (`DEVELOPMENT_TEAM = R5TMQ2Q9WM`, "Adenuga Adewumi") is a **free Personal
  team**, which **cannot use Sign in with Apple** — `flutter run` to a device failed with
  *"Personal development teams … do not support the Sign In with Apple capability"* and the
  provisioning profile lacked `com.apple.developer.applesignin`. Worse, with the entitlement
  wired this broke **all** iOS device builds (Google included), so the
  `CODE_SIGN_ENTITLEMENTS` references were **removed from `project.pbxproj`** (the
  `ios/Runner/Runner.entitlements` file is left in place but dormant/unreferenced for later).
  The user separately has access to a **company paid account** for a *different* project —
  but using it would register `com.finclar.finclarAi`'s App ID/profiles/capability under that
  company (visible to their portal admins; App Store releases would ship under their legal
  entity). **To enable Apple later:** get a paid membership we control (or explicit permission
  on the company team), set `DEVELOPMENT_TEAM` to it, re-add `CODE_SIGN_ENTITLEMENTS =
  Runner/Runner.entitlements` to the 3 Runner configs (or add the capability via Xcode UI),
  enable the Apple provider in Firebase, then flip `kAppleSignInEnabled = true`.
- **iOS push pending APNs setup:** FCM works on Android in debug; iOS needs an APNs
  `.p8` key uploaded to Firebase (Cloud Messaging) + Push/Background-Modes capabilities
  in Xcode, and a **paid** Apple Developer account. `NotificationService._registerToken`
  is a stub until a device-token endpoint exists in `docs/API.md`.
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

### 2026-07-23 — Centralized category picker (with create-your-own) across expenses + budget
- Problem: the category picker in the **add-manual-expense** sheet (`+` bottom-nav →
  "Type expense" → `showEditExpenseSheet` → `showExpenseCategorySheet`) had no way to
  create a new category, while the budget picker did.
- Fix: made `showExpenseCategorySheet` the single centralized picker. Added an
  "Add category" button to it that opens the new `expense_add_category_sheet.dart`
  (moved out of budget; creates a category via `expenseRepositoryProvider.createCategory`
  and invalidates `categoriesProvider`).
- `budget_category_sheet.dart` now just delegates to `showExpenseCategorySheet`
  (keeps its `showBudgetCategorySheet(selected:)` signature, used by
  `budget_allocation_sheet.dart`). Deleted `budget_add_category_sheet.dart` (dupe).
- Result: expense add/edit, scanned-item edit, and budget allocation all share one
  picker with the create-category option.

### 2026-07-22 — Analytics + Crashlytics (Firebase) so the owner can see engagement

Added product analytics and crash reporting so a **non-technical** stakeholder can
answer "how are people using the app" from the Firebase Console (Analytics →
Dashboard/Engagement/Retention) — no in-app admin dashboard built yet (deferred until
we know which numbers the owner keeps asking for).

- **Packages:** `firebase_analytics: ^11.3.3`, `firebase_crashlytics: ^4.1.3`
  (firebase_core was already present; iOS/Android google config files already in place).
- **`Analytics` wrapper** — `lib/core/services/analytics_service.dart`, same
  `abstract class` + static style as `NotificationService`/`Log`. Features never touch
  `FirebaseAnalytics`/`FirebaseCrashlytics` directly. Kept decoupled from feature models
  (`identify()` takes primitives, not `UserModel`).
- **Automatic screen tracking:** `Analytics.observer` (FirebaseAnalyticsObserver) added
  to `GoRouter(observers:)` in `app_router.dart` — logs `screen_view` per navigation,
  zero per-screen code.
- **Crash reporting:** `Analytics.init()` in `main.dart` routes `FlutterError.onError`
  and `PlatformDispatcher.onError` into Crashlytics. Added the
  `com.google.firebase.crashlytics` Gradle plugin (settings + app `build.gradle.kts`).
- **Identity:** `Analytics.identify()` fired from the single choke point
  `UserProfileNotifier._fetchAndCache`; `Analytics.clearUser()` on `authStateService.logOut`.
- **Business events instrumented** (fired from notifier/provider success points, not
  repositories): `login` (passcode/social), `sign_up` (email), `bank_linked`,
  `expense_added` (manual/receipt), `receipt_scanned`, `budget_created`, `group_created`,
  `clara_message_sent`.
- **Not done / next:** invite the owner to the Firebase project as a Viewer; consider a
  small in-app analytics page later if the Console proves too raw. New events must go
  through the `Analytics` wrapper.

### 2026-07-20 — Subscriptions wired to live API + Paystack checkout

- Subscriptions turned out to be **live** under `/subscriptions/*` (docs had guessed
  `/subscription/*` and listed it as not-yet-live). Diffed against the live OpenAPI spec;
  `docs/API.md` now documents plans / me / checkout-verify / cancel / resume + both DTOs.
- New: `plan_model.dart`, `subscription_model.dart`, `subscription_repository.dart`,
  `subscription_providers.dart`, `subscription_skeleton.dart`,
  `core/services/paystack_checkout_service.dart`.
- The screen and both sheets were **fully hardcoded** (₦28,000, "March 7, 2026 – March 8,
  2027", a static feature list, a fake success snackbar). All now render live data;
  cancel/resume hit the real endpoints. The feature list comes from `PlanDto.features`
  and the "Save 5%" badge is computed from `compare_at_amount`.
- Settings row now branches: subscribed → active-subscription sheet (badge "Clara +"),
  otherwise → upgrade screen. `showActiveSubscriptionSheet` had been orphaned — nothing
  called it before.
- **Rejected `flutter_paystack_max`** (was the initial pick): it calls Paystack's
  `/transaction/initialize` **from the client with the secret key**
  (`PaystackTransactionRequest.secretKey` is required). Shipping a Paystack secret key in
  a mobile binary hands anyone who decompiles it full account access — refunds, charges,
  every customer's transactions. Went with `webview_flutter` + Paystack **inline JS**,
  which is designed for the public key and matches what the backend already hands us.
  `webview_flutter` was already a transitive dep; promoted to direct.

**Verified / open:**
- ✅ **Money units confirmed** (2026-07-20 live log): `amount` is minor units (kobo) —
  monthly `300000` = ₦3,000. ÷100 is correct. Live key is `pk_live_...`.
- ⚠️ **Checkout WebView origin matters.** First live run failed with
  `ERR_BLOCKED_BY_RESPONSE`: Paystack's inline popup embeds an iframe from
  `checkout.paystack.com` (X-Frame-Options: SAMEORIGIN), so the `loadHtmlString`
  `baseUrl` **must** be `https://checkout.paystack.com` to keep the frame same-origin.
  Was `finclarai.com` initially → blocked. Re-test the full payment after this fix; a
  successful reference still needs to round-trip through `/checkout/verify`.
- Backend has no webhook-driven refresh wired to the client; `subscriptionProvider` only
  updates on explicit verify/cancel/resume or refresh.

### 2026-07-20 — Parent-expense edit on the itemised (receipt) expense screen
- Expenses with line items open `ScannedExpenseScreen`, whose top bar only had
  back + title + delete. Added an **Edit pill** to the left of delete, matching the
  `ExpensePreviewTopBar` pill used by item-less expenses.
- Edit opens the **same** `showEditExpenseSheet`, so parent edits go through
  `PATCH /expenses/{id}` and now actually persist across a refresh (previously only
  local item edits changed, which never survived a reload).
- `ScannedReceiptModel` gained `sourceExpense` (the originating `ExpenseModel`), set in
  `fromExpenseModel`. The edit sheet needs the category + date, which the receipt model
  alone doesn't carry. The Edit pill is **hidden when `sourceExpense == null`** — i.e. the
  fresh-OCR flow, where nothing is saved server-side yet.
- `showEditExpenseSheet` gained `hasItems`; when true it renders an **"Apply this category
  to all items in this expense"** checkbox under the category row.
- **Line-item editing now persists.** `UpdateExpenseDto` gained an `items` array
  (`UpdateExpenseItemDto {id required, name?, quantity?, unit_price?, category_id?}`) — this
  is the *only* way to edit an item; there is still no per-item endpoint. Wired through:
  new `ExpenseItemUpdate` payload model → `ExpenseRepository.updateExpense(items:)` →
  `ExpenseListNotifier.edit(items:)`. The category cascade rides along in the **same PATCH**
  as the parent edit rather than a separate batch call.
- `ScannedExpenseScreen._onSave` now diffs items against a baseline snapshot
  (`_originalItems`) and PATCHes only genuinely-changed ones — this is what fixes the
  long-standing "edit an item, save, refresh, changes gone" bug.
- `ScannedItemModel` gained `serverId` + `categoryId`. `serverId` is null for a
  freshly-scanned unsaved receipt, and **only items with a `serverId` are sent** (the OCR
  flow's synthetic `name_price` ids are not valid uuids).
- Item tiles resolve their category **name** from `categoriesProvider` by `categoryId`;
  `fromExpenseModel` hardcodes `'Other'` since the model has no name to work with, so
  without this a cascade appeared to do nothing.
- Corrected a stale base URL in `CLAUDE.md` (still said `finclar-ai.onrender.com`; the app
  and `docs/API.md` have been on `api.finclarai.com` since 2026-06-13).

### 2026-07-20 — Cold-start resilience for home dashboard fetches
- **Bug:** after the app sat idle, opening it left balance/income-expense chart/budget
  empty while recent-expenses + home-insight loaded. Cause: cold/slow backend +
  ~6 concurrent home GETs; some hung the full 120s timeout, and their
  `FutureProvider`/`AsyncNotifier` builds went to a permanent error state with no
  retry. Pull-to-refresh (now warm server) fixed it — masking the real issue.
- **Fixes:**
  - New `lib/core/api/interceptors/retry_interceptor.dart` — auto-retries idempotent
    **GET**s on timeout/connection errors, `maxRetries` (3) with exponential backoff
    (0.4/0.8/1.6s). Never retries writes or 4xx/5xx. Wired into `ApiClient` after
    auth, before logging. (`maxRetries` was previously a dead constant.)
  - `AppConstants` connect/receive timeouts **120s → 30s** so a hung request fails
    fast and the retry hits the warming server.
  - `BalanceCard` + `IncomeExpenseChartSection` error branches no longer show a fake
    ₦0 / empty state — they render a tappable "—"/"tap to retry" that
    `ref.invalidate(homeSummaryProvider)`.
  - Launch warm-up: `ServerWarmupService.ping()` in `main()` fires a fire-and-forget
    unauth `GET /health` to wake the server before heavy authed queries. Added
    `ApiEndpoints.health` and `AppIcons.refresh`.

### 2026-07-13 — Fastlane + Firebase App Distribution release pipeline (commit-driven versioning)
- Added a root-level `fastlane/` pipeline. Version is the single source of truth in `pubspec.yaml` (`X.Y.Z+BUILD`).
- **Version name** bumped from Conventional Commits since the last `vX.Y.Z` tag: `feat!`/`BREAKING CHANGE` → major, `feat` → minor, `fix` → patch, others → none. Logic is hand-written in `fastlane/Fastfile` (not a plugin). **Build number** = `git rev-list --count HEAD` (auto, monotonic).
- Lanes: `fastlane bump [dry_run:true|bump:major]`, `fastlane android beta`, `fastlane ios beta`, `fastlane beta [skip_ios:true|skip_git:true]` (full = bump → build both → commit + tag `vX.Y.Z` + push). Verified: dry-run correctly read 17 commits → `1.0.0` → `1.1.0+17`, pubspec left untouched.
- Uploads via `fastlane-plugin-firebase_app_distribution` (Firebase project `finclar-ai`, app IDs in `fastlane/.env.default`). Needs `fastlane/firebase-service-account.json` (gitignored) — user must download from Firebase console.
- **Android** release signing wired in `android/app/build.gradle.kts`: uses `android/key.properties` (gitignored) when present, falls back to debug signing when absent. `android/key.properties.example` + keytool command in `docs/RELEASE_PIPELINE.md`.
- **iOS** lane fully wired but **blocked on a paid Apple Developer account** (free accounts can't sign; app uses Sign in with Apple = paid-only). `ios/ExportOptions.plist` = ad-hoc, team R5TMQ2Q9WM. Ad-hoc export earlier failed: account "Adenuga Adewumi" lacks distribution-profile permission. User plans to enroll their own individual account. Use `fastlane beta skip_ios:true` until then.
- Fastlane needs a UTF-8 locale (LANG/LC_ALL set in `fastlane/.env.default`) or it crashes parsing non-ASCII commit messages.
- Full setup/usage guide: `docs/RELEASE_PIPELINE.md`.

### 2026-07-10 — Clara chat: blinking-cursor typewriter + staged animated chart reveal
- Refinement of the same-day typewriter/chart work below, per user feedback.
- **Blinking cursor + slower reveal.** `ClaraAssistantBubble` now renders the reveal via
  `Text.rich` with a `WidgetSpan` caret (2×15 rounded bar, `AppColors.primary`) that blinks
  on a 560ms repeating controller while typing and disappears on completion (`_reveal.forward().whenComplete(stop blink)`). Reveal speed slowed to ~32ms/glyph via the shared
  `claraRevealDuration(text)` helper (moved into `clara_message_model.dart` so the screen and
  bubble agree). Controllers are only created for the animating reply — history bubbles render
  plain `Text` and spin up nothing.
- **Chart is revealed AFTER the text, then fades + rises.** The insight card no longer pops in
  with the text. `ClaraInsightCard` is now stateful (`animate` + `startDelay`): the screen
  computes `startDelay = claraRevealDuration(replyText) + 180ms` and passes it, so the card
  waits for the typewriter to finish, then plays an 850ms controller — opacity 0→1 over the
  first ~45%, a 10px slide-up, and the **bars rising** from the baseline. Provider tracks the
  reply's insight id (`animateInsightId`, alongside `animateMessageId`); only the fresh reply
  animates, never history.
- **Bar-rise animation added to the shared chart** (opt-in, home unaffected). `AppBarChart`
  gained `progress` (0..1, default 1.0): bar heights and the reference-line Y are multiplied
  by it, so bars grow from the baseline and any line rises with them. `IncomeExpenseChartSection`
  gained `chartProgress` (default 1.0) forwarded to `AppBarChart`. Because bars are `Positioned`
  widgets (not baked into a painter), the Clara card animates them by rebuilding the section
  with a rising `chartProgress` each frame — no painter changes. Home passes nothing → renders
  fully drawn exactly as before. All-zero months still safe (`_niceMaxY` guards `rawMax<=0`).
- `flutter analyze` clean. Not yet device-tested by the user as of this entry.

### 2026-07-10 — Clara chat polish: typewriter reveal + home-style income/expense chart
- **Typewriter effect + haptic** on Clara's replies. `ClaraAssistantBubble` is now a
  `StatefulWidget` taking `animate`; when true it reveals the text glyph-by-glyph via an
  `AnimationController` (IntTween over `text.characters`, so emoji/surrogate pairs never
  split), ~22ms/glyph clamped 350ms–2.6s, and fires a single `HapticFeedback.lightImpact()`
  as the reveal begins. Only the **freshly received** reply animates, never history: the
  provider records the reply's text-bubble id in `ClaraChatState.animateMessageId` (set in
  `sendText`), the screen passes `animate: msg.id == animateMessageId`, and every bubble now
  has a `ValueKey(msg.id)` so the animating bubble's State persists (animates once in
  `initState`, doesn't restart on later rebuilds like the typing-indicator toggle).
- **Insight chart now reuses the home dashboard chart.** Per the user's request, Clara's
  expense-summary card renders through `IncomeExpenseChartSection`
  (`features/home/.../income_expense_chart_section.dart`) fed with explicit
  `data`/`totalIncome`/`totalExpense` — the same grouped striped income-vs-expense bars +
  legend as home, instead of the old single-series bar. `ClaraInsightModel` was reshaped:
  dropped `ClaraChartPoint{label,value}`, added `ClaraTrendPoint{month,income,expense}` and a
  `trend` list; `fromSummary` maps the backend `income_expense_trend` (month→income,expense).
  `ClaraInsightCard` is now a thin bordered wrapper around the home section. All-zero months
  (e.g. a fresh account's July) render fine — `AppBarChart._niceMaxY` already guards
  `rawMax <= 0 → 1.0` and bar heights guard `maxY > 0`, same as on home.
- `flutter analyze` clean. Not yet device-tested by the user as of this entry.

### 2026-07-10 — Clara AI chat wired to live backend (REST, not socket)
- Backend dev shipped Clara as a **REST** chat (commit `57659fc` — OpenAI tool-calling over
  the user's expense data). Verified against her repo (`app/module/clara/`): two endpoints,
  **not** a WebSocket (unlike group chat).
  - `POST /clara/chat` `{message}` → `ApiResponse<{reply, data}>` where `data` is a nullable
    `ExpenseSummaryDto` (same shape as `GET /expenses/summary`) the model renders as the
    insight chart card. Backend persists BOTH the user msg and the reply.
  - `GET /clara/messages` → `PaginatedResponse<ClaraMessageDto>` history; each item
    `{role, content, data, created_at}` — **no message id**. Clara only talks about the
    user's own finances (system prompt refuses off-topic).
- Client wiring (replaced the old local mock `_replyFor` simulator):
  - `ApiEndpoints.claraChat` / `claraMessages` added.
  - `clara_message_model.dart`: added `ClaraMessageModel.listFromBackend(json)` (expands one
    backend message → text bubble + optional insight card) and
    `ClaraInsightModel.fromSummary(ExpenseSummaryDto)` (title=`month_label`,
    income=`monthly_income`, expense=`total_expense`, bars from `income_expense_trend`
    (value=`expense`) falling back to `monthly_trend` (value=`total`)). No backend id → keys
    are synthesized from `created_at`+role+content hash with `_t`/`_i` suffixes.
  - New `ClaraRepository` (`getHistory` via `getAllPaginated`, `sendMessage` parsing
    `{reply,data}` into 1–2 messages) + `claraRepositoryProvider`.
  - `ClaraChatNotifier` rewritten: `build()` loads history (skeleton via new
    `isLoadingHistory`/`hasError` on `ClaraChatState`); `sendText` posts to the API, appends
    the reply, keeps the typing indicator, and **rethrows** `AppException` so the screen
    snackbars on failure (typing always cleared). `retryHistory()` for the error state.
  - `clara_chat_screen.dart`: new `_Body` switch → skeleton / error+retry / empty / list;
    `_send` catches `AppException` → `AppSnackbar.error`; input disabled while typing OR
    loading history. Bubble/insight-card rendering unchanged (one assistant reply with a
    summary still shows as a text bubble followed by the chart card).
  - `session_reset.dart`: added `claraChatProvider` so history clears on logout.
- `flutter analyze` clean. Not yet device-tested by the user as of this entry.

### 2026-07-09 — Clara AI chat: global floating button + chat screen (UI-only)
- New `clara` feature (`lib/features/clara/`) built from the Figma Clara AI design
  (node `29:10414`). Screen `clara_chat_screen.dart`, route `RouteNames.clara`
  (`/clara`, outside the shell), pushed via `context.push`.
- Global launcher `ClaraFab` (`shared/widgets/clara_fab.dart`) — gradient "Ask Clara"
  pill — added to `AppShell`, so it floats bottom-right on all 4 bottom-nav pages
  (home/expenses/budget/group). Body is now wrapped in a `Stack`.
- **UI-only / simulated replies:** there is no `/ai/chat` backend (docs/API.md confirms;
  home insight is `GET /insights/home`). `claraChatProvider` (`NotifierProvider`) holds
  messages + `isTyping` and returns canned replies locally — asking about income/expense
  returns a demo `ClaraInsightCard` (income/expense figures + simple bar chart). Swap the
  reply logic for a real endpoint when one exists.
- Widgets: `clara_chat_bubble` (white user pill / plain-text Clara reply),
  `clara_insight_card`, `clara_input_bar`, `clara_empty_state` ("No Insights Yet"),
  `clara_suggestions` (prompt chips), `clara_typing_indicator`. Uses `AppColors.claraGradient`.

### 2026-07-09 — Fixed: chat "Couldn't load messages" on first open (never even called the API)
- Follow-up to the previous entry's rewrite. Symptom after wiring `group_chat_screen.dart`
  to real data: opening a chat always hit the error screen on **first** load; tapping
  Retry always fixed it. The 500ms auto-retry added as a first attempt at this (see below)
  didn't help — the user confirmed the `GET /messages` request **never fired at all** on
  first open (no request in the network log), only after manually tapping Retry.
- **Root cause:** `GroupMessagesNotifier.build()` opened with
  `ref.read(activeGroupChatIdProvider.notifier).state = groupId;` — a *synchronous* write
  to a different provider's state while this provider's own `build()` was still executing.
  Because the chat screen's top bar (`groupDetailProvider`) and message list
  (`groupMessagesProvider`) both build in the **same Flutter frame**, this hit Riverpod's
  guard against modifying a provider while it (or something in the same build pass) is
  still initializing, and threw — aborting `build()` **before** it ever reached the
  `getMessages` call below. `refresh()` (what the Retry button calls) is a plain method
  invoked from a tap handler, not part of any provider's build phase, so it was never
  subject to the same restriction — which is exactly why retry always "just worked."
- **Fix:** wrapped the mutation in `Future.microtask(() { ... })` so it runs after the
  current build pass completes instead of during it. One-line change in
  `group_messages_provider.dart`; the `AsyncNotifierProvider`/hub/dedupe architecture is
  otherwise unchanged.
- Audited the codebase for the same pattern (`grep ".notifier).state ="`) — the only other
  hit (`spending_screen.dart`'s month picker) runs from a widget's `onTap`, not from inside
  another provider's `build()`, so it isn't affected by this class of bug.
- The earlier 500ms auto-retry-on-failure in `_fetchHistoryWithRetry` is left in place —
  harmless, and still a reasonable guard against a genuine transient network blip on first
  load (distinct from this bug, which never reached the network call at all).
- `flutter analyze` clean. Not yet re-confirmed on-device by the user as of this entry.

### 2026-07-08 — Found + fixed: group_chat_screen.dart was never wired to real data
- **Root cause of "I'm receiving messages in my logs but the chat isn't updating":**
  every piece of the chat backend (repository, `GroupChatSocketService`, the hub,
  `groupMessagesProvider`) was built and wired correctly across the socket-implementation
  work — but `group_chat_screen.dart` itself was **never rewritten** to read from
  `groupMessagesProvider`. It was still rendering the original hardcoded mock conversation
  (`_buildDays()`/`_Msg`/`_Day`) from before any backend work started. The socket layer was
  provably working (visible in logs); the screen just wasn't looking at it.
- **Fixed:** `group_chat_screen.dart` rewritten as `ConsumerStatefulWidget` —
  `ref.watch(groupMessagesProvider(group.id))` drives the list (skeleton / error+retry /
  empty / real `GroupMessageModel` bubbles per CLAUDE.md §8); send button calls
  `.sendText()`; camera/attachment flow calls `.sendAttachment()` then, if a caption was
  typed, a follow-up `.sendText()` (the backend's `POST /messages/attachment` has no
  caption field — combined caption+image isn't representable in one message, so it's sent
  as two). Own-vs-other bubble side determined by `message.senderId == currentUserId`
  (`userProfileProvider`), not a hardcoded flag. Top bar now shows real member avatars/
  count from `groupDetailProvider(group.id)` instead of two fake hardcoded names ("James
  Fanny"/"Sarah Collins") and a fake "10 friends" pill. Dropped the fake
  `GroupChatTypingBubble` usage (implied a fabricated presence signal — no backend support
  for real typing indicators) and the fake infinite-scroll-older-messages mock; the widget
  class itself is left in `group_chat_bubble.dart` unused, ready for when/if the backend
  adds real typing events.
- **Known gap, not fixed here (separate follow-up):** history is still a single REST page
  (`GET /messages` default `page=1&limit=50`, no older-page pagination wired) — acceptable
  for now since groups are new and message counts are low, but will need real infinite-
  scroll pagination once a group's history exceeds 50 messages.
- `flutter analyze` clean.

### 2026-07-08 — In-app group chat notifications (banner + tap-to-navigate)
- Scope decision (asked user): **in-app only** for now, not real push. True background/
  killed-app push needs the backend to trigger FCM on new messages + a device-token
  registration endpoint — neither exists (confirmed against her repo: no FCM trigger
  anywhere; our own `NotificationService._registerToken` is still a stub). In-app works
  today because it rides the existing chat WebSocket while the app process is alive.
- **Architecture change, not just a banner bolt-on:** previously each open chat screen
  (`groupMessagesProvider`) opened its own `GroupChatSocketService`. To notify about
  messages in groups the user *isn't* currently viewing, something needs a live socket to
  *every* group at all times — but the backend's connection manager keys a socket by
  `(group_id, user_id)`, so a second simultaneous connection to the same group from this
  device would silently **replace** the first in the server's broadcast map (first socket
  goes zombie — stays "open" but stops receiving events, no error). Two sockets to the same
  group was therefore not an option.
- **Fix: single connection owner.** New `core/services/group_chat_hub_service.dart —
  `GroupChatHubService` owns exactly one socket per group for the whole app session, with
  its own per-group exponential-backoff reconnect (3s→30s cap, mirrors the old per-screen
  logic). Nothing else may construct `GroupChatSocketService` directly anymore.
- New `features/group/providers/group_chat_hub_provider.dart`:
  - `groupChatHubProvider` — the hub singleton (disposed via `ref.onDispose` → closes every
    socket).
  - `activeGroupChatIdProvider` — `StateProvider<String?>` set by whichever chat screen is
    currently mounted; the notifications controller skips banners for that group.
  - `groupChatNotificationsProvider` — `GroupChatNotificationsController`: on start, listens
    to `groupsProvider` (`fireImmediately: true`) and calls `hub.connectTo(id)` for every
    group so all of them stay connected in the background, not just the one being viewed.
    On an incoming message it skips if the sender is the current user or the group is
    `activeGroupChatIdProvider`, otherwise shows a `toastification` banner (title = group
    name, body = "sender: content", "Sent an attachment" for images) — tapping it resolves
    the `GroupModel` (from the cached list, or `GET /groups/{id}` if not cached yet) and
    calls `appRouter.push(RouteNames.groupChat, extra: group)` directly — **no
    `BuildContext` needed**, since `appRouter` (the `GoRouter` instance) exposes `push` as
    an instance method and `toastification.show` falls back to the app-root overlay
    registered by `ToastificationWrapper` in `app.dart` when no `context` is passed.
  - Bootstrapped by `AppShell.build` (`ref.watch(groupChatNotificationsProvider)` — now a
    `ConsumerWidget`). Not autoDispose, so it persists across navigation (including screens
    pushed outside the `ShellRoute`, e.g. the chat screen itself) until logout invalidates it.
- **`group_messages_provider.dart` rewritten** to stop owning a socket: it calls
  `hub.connectTo(groupId)` (idempotent — a no-op if the hub already has it from the
  notifications controller), listens to `hub.events.where((e) => e.groupId == groupId)`,
  and sends via `hub.sendText`. Sets `activeGroupChatIdProvider` on mount, clears it on
  dispose (guarded so a fast screen-swap can't clobber a newer chat's active-id). Dedupe-
  by-id logic unchanged. Leaving the chat screen no longer closes the socket — the hub
  keeps it open for background notifications.
- **`session_reset.dart`**: added `groupChatNotificationsProvider`, `groupChatHubProvider`,
  `activeGroupChatIdProvider` to the invalidation list (alongside `groupsProvider`/
  `friendsProvider`/`friendInvitesProvider`, added in the same pass) — logout now closes
  every group socket and tears down the notification listeners so the next login's
  `AppShell` mount re-subscribes clean, with zero risk of the previous account's group
  messages leaking into the new session.
- `flutter analyze` clean. Not yet device-tested (needs a message to arrive while the app
  is open on a different screen than that group's chat — single-device testable per the
  existing self-echo trick, just navigate away from the chat first).

### 2026-07-06 — Backend now broadcasts REST-sent messages + attachments (no client change)
- Backend commit `ba27006` added `ws_manager.broadcast(...)` to **both** `POST /messages`
  and `POST /messages/attachment`, closing the gap noted the same day: attachments (and
  REST-sent text) now reach all connected members live, not just on refetch.
- **No client code change was needed** — `groupMessagesProvider._append` already dedupes
  by message id, so the attachment we append locally (from the REST response) is not
  duplicated when the backend's broadcast of that same message echoes back over the socket.
- Updated `docs/API.md` WS section to drop the old "attachments not broadcast" caveat.
  The WS *receive* loop is still text-only (`{"content":...}`), so attachments still
  **upload via REST** — that part is unchanged and correct.

### 2026-07-06 — Group chat moved to live WebSocket (Starlette backend)
- Backend dev implemented chat over a FastAPI/Starlette WebSocket. Verified the contract
  against her repo (`ayoolat/finclair-ai`, `app/module/groups/router.py` +
  `ws/connection_manager.py`) — documented in `docs/API.md` (`WS /groups/{id}/ws`).
- **Contract:** `wss://api.finclarai.com/api/v1/groups/{group_id}/ws?token=<access_token>`
  (token as **query param** — WS can't send an auth header; closes 4001 invalid / 4003
  non-member). Server sends `{"type":"connected"}` on open, broadcasts
  `{"type":"message","data":<MessageResponseDto>}` to **all members incl. sender**,
  and `{"type":"error","message":...}`. Client sends `{"content":"..."}` (**text only**).
- **Added package** `web_socket_channel: ^3.0.1` (approved via the "implement this" ask).
- **New** `core/services/group_chat_socket_service.dart` — isolates `web_socket_channel`
  (UI/providers never touch it directly, per BankConnectService pattern). Parses the wire
  events into a sealed `GroupChatSocketEvent` (`Connected`/`IncomingMessage`/`Error`),
  `sendText`, `connect()` (awaits `channel.ready`), `dispose()`. `ApiEndpoints.wsBaseUrl`
  (http→ws) + `groupChatSocket(id, token)` helper added.
- **`groupMessagesProvider` is now `AsyncNotifierProvider.autoDispose.family`** — loads
  REST history, opens the socket in the background, appends incoming `message` events
  **deduped by id**, and auto-reconnects (3s timer) on drop. autoDispose so the socket
  closes when the chat screen is popped. `_teardown` cancels timer/sub + disposes socket.
- **Key gotchas baked in:** (1) text is sent over the **socket**, not `POST /messages`,
  because the REST send doesn't broadcast; (2) the sender's own message echoes back via
  broadcast, so we **don't** append optimistically — we dedupe by id; (3) **attachments
  stay REST-only and are NOT broadcast** by the backend, so `sendAttachment` appends
  locally and other members won't see it live until refetch/reconnect (backend TODO).
- `sendText`/`sendAttachment` keep the same signatures, so `group_chat_screen.dart`
  is unchanged. `flutter analyze` clean.

### 2026-07-06 — Group + Friends feature wired end-to-end to live API
- Built the full data/provider/UI stack for the group-savings + friends feature
  (previously all mock). `flutter analyze` clean across the project.
- **Models** (`features/group/data/models/`): `friendship_model.dart`
  (`FriendshipModel` + `FriendshipStatus` + `UserSearchResultModel`),
  `group_model.dart` (`GroupModel` + `copyWith`), `group_member_model.dart`
  (`GroupMemberModel` + `GroupMemberStatus`), `savings_entry_model.dart`,
  `group_message_model.dart` (`GroupMessageModel` + `MessageRole`/`MessageType`).
  **Money fields are strings on these DTOs** → parsed with `double.tryParse`.
  Deleted the old mock `group_item.dart`.
- **Repositories**: `FriendRepository` (search/list/invite/invites/accept/decline/
  remove), `GroupRepository` (groups CRUD, leave, share-link, member update/remove,
  savings GET + multipart POST, messages GET/POST + multipart attachment).
- **Providers**: `friend_providers.dart` (`friendRepositoryProvider`,
  `userSearchProvider` family, `friendsProvider`, `friendInvitesProvider`),
  `group_providers.dart` (`groupRepositoryProvider`, `groupsProvider`,
  `groupDetailProvider` family, `groupSavingsProvider` family),
  `group_messages_provider.dart` (`groupMessagesProvider` family, held ascending).
- **Screens wired**: group list (`groupsProvider`, skeleton/empty/error, pull-to-
  refresh, cycled accent colors since backend has no per-group color); create group
  (real `POST /groups` with `member_ids`, `pushReplacement` to detail); group detail
  (`groupDetailProvider` stats + members, leave, share via `GET /groups/{id}/share`
  with fallback to `shareable_link`, owner-gated member edit/remove, "Add savings"
  → record-savings sheet); group friends (members list, owner-gated remove); group
  chat (`groupMessagesProvider`, real send text + image attachment, day-grouped
  bubbles, network-image bubbles, empty/skeleton/error). Removed the chat's mock
  Clara-pull easter egg, typing indicator, and fake load-more.
- **New widgets**: `select_friend_sheet.dart` (pick group members from accepted
  friends, with an "invite a new friend" CTA), `record_savings_sheet.dart` (amount +
  note + optional receipt → `POST /groups/{id}/savings`). Rewrote `add_friend_sheet`
  (debounced `GET /friends/search` → `POST /friends/invite`) and `edit_friend_sheet`
  (returns the new target amount + takes currency symbol). Added network-image +
  system-message bubbles to `group_chat_bubble.dart`.
- **Routing**: `group_detail`/`group_friends`/`group_chat` `extra` is now `GroupModel`
  (was mock `GroupItem`). Added `friends*` + `group*` sub-path constants in
  `api_endpoints.dart`. `session_reset.dart` now invalidates `friendsProvider`,
  `friendInvitesProvider`, `groupsProvider` on login/logout.
- **Owner gating:** member edit/remove only show when `group.ownerId == /user/me id`
  and not for your own row. Backend still enforces; failures surface via `AppSnackbar`.
- **Known gaps (UI only, backend supports them):** no dedicated friend-invites inbox
  screen (accept/decline providers exist but aren't surfaced); no edit-group /
  delete-group UI (`updateGroup`/`deleteGroup` exist on repo/provider); attachment
  caption is sent as a **separate** follow-up text message (the attachment endpoint
  takes no caption field); message list loads first 50 only (no chat pagination yet);
  the pre-existing `friends_limit_sheet`/`group_limit_sheet` upsell sheets remain
  unused. `record_amount` on the attachment endpoint is not yet used from the UI.

### 2026-07-06 — Groups + Friends backend now fully live (docs only, not wired)
- Diffed the live OpenAPI spec (`https://api.finclarai.com/openapi.json`) against
  `docs/API.md` — the **Groups feature is no longer blocked**. Two new route groups
  landed on the backend that weren't documented at all:
  - **Friends**: `GET /friends/search`, `GET /friends`, `POST /friends/invite`,
    `GET /friends/invites`, `PUT /friends/invites/{id}/accept`,
    `PUT /friends/invites/{id}/decline`, `DELETE /friends/{friendship_id}`.
  - **Groups (group savings)**: full CRUD (`GET/POST /groups`,
    `GET/PUT/DELETE /groups/{id}`), `POST /groups/{id}/leave`,
    `GET /groups/{id}/share` (invite link), member management
    (`PUT/DELETE /groups/{id}/members/{member_id}`), savings entries
    (`POST/GET /groups/{id}/savings` — multipart, optional receipt), and chat
    (`GET/POST /groups/{id}/messages`, `POST /groups/{id}/messages/attachment`).
  - Also newly documented: `POST /categories` (create custom category — was already
    wired in `ApiEndpoints.categories` but undocumented as POST), and two public
    marketing endpoints (`POST /marketing/newsletter/subscribe`, `POST /marketing/waitlist`)
    — these are for the marketing website, not the mobile app.
- Updated `docs/API.md` (new Friends + Groups + Marketing sections, new schemas:
  `UserSearchResultDto`, `FriendshipResponseDto`, `GroupResponseDto`,
  `GroupDetailResponseDto`, `GroupMemberResponseDto`, `SavingsEntryResponseDto`,
  `MessageResponseDto`; removed Groups from "Planned / Not Yet Live").
- Added the new path constants to `lib/core/api/api_endpoints.dart` (`friends*`,
  `groupLeave`, `groupShare`, `groupMember`, `groupSavings`, `groupMessages`,
  `groupMessageAttachment` — `groups`/`group` already existed under the old
  "planned" section, now moved to a live section). Updated `CHECKLIST.md` §8.
- **Money fields on Group/Savings DTOs are strings** (`target_amount`, `total_raised`,
  `balance`, `contributed_amount`, `amount`), same convention as `ExpenseResponseDto`/
  `IncomeResponseDto` — parse with `double.tryParse()`, not like the summary/budget
  endpoints which use numbers.
- **Not yet wired in app** — no repository/providers for friends or groups yet. The
  existing `group` feature UI (list/create/detail/chat/add-friend screens) still runs
  on mock data. This is the next real unblock for that feature area.

### 2026-06-29 — Mono live test: client works end-to-end, blocked on backend 400
- Tested on a real iPhone with public key `test_pk_m5bdk3o9hoqfp50eav1x`
  (in `env.json` as `MONO_PUBLIC_KEY`; matching secret `test_sk_zucn1b21ee7bd6izg2ff`
  is **backend-only**, never in the app). Mono Connect opens, user picks bank +
  account, returns a valid `code_…`.
- **Fixed a real bug:** `mono_flutter`'s `launch()` does `Navigator.push(...).then()`
  but does **not return that Future**, so `await launch()` resolved instantly and
  the code was always null → flow silently returned to bank selection.
  `BankConnectService.launch` now drives a `Completer<BankConnectResult>` off the
  `onSuccess`/`onClosed` callbacks instead of awaiting `launch()`.
- After the fix `POST /banks/link {code}` fires correctly but the **backend
  returns 400** — the server-side Mono code exchange fails. **Root cause is on the
  backend (escalated by user):** its Mono secret key must be the pair of the app's
  public key. Client is done; waiting on backend fix to verify link → auto-sync →
  success screen.
- Improved `logging_interceptor.onError` to log `statusCode` + response body
  (previously only `err.message`), so future API failures show the backend message.

### 2026-06-29 — Bank flow wired to live API
- Built full data layer for banks: `BankModel` + `AvailableBankModel`
  (`features/expenses/data/models/bank_model.dart`), `BankRepository`
  (`features/expenses/data/repositories/bank_repository.dart`), and
  `bank_providers.dart` (`bankRepositoryProvider`, `availableBanksProvider`,
  `linkedBanksProvider` as `AsyncNotifier` with link/unlink/sync/refresh).
- **`bank_selection_screen`** → `ConsumerStatefulWidget`; loads from
  `GET /banks/available` with skeleton rows while loading; search filters the
  live list.
- **`bank_linking_sheet`** → refactored to `Future<BankModel?>`-returning sheet.
  Takes an `onLink: Future<BankModel> Function()` param; handles success (pops
  with the linked `BankModel`) and failure (shows retry).
- **Mono Connect IS integrated** (added `mono_flutter ^4.0.4`). New
  `core/services/bank_connect_service.dart` (`BankConnectService.launch`) wraps
  the SDK (UI/providers never touch it directly, per BiometricService pattern).
  `bank_selection_screen._onBankTap` launches Mono → gets the one-time `code` →
  `showBankLinkingSheet` calls `linkedBanksProvider.notifier.link(code)` →
  `POST /banks/link` → success screen.
  - **Public key:** `AppConstants.monoPublicKey` via
    `--dart-define=MONO_PUBLIC_KEY=test_pk_...` (empty → service returns
    `notConfigured`, screen shows a snackbar). A Mono *public* key is safe in the
    binary; the code is exchanged server-side.
  - **Customer info:** passes the logged-in user's `username` + `email` as the
    Mono customer (BVN not required for `scope: "auth"`).
  - ⚠️ **We do NOT pre-select the institution** — Mono's institution id ≠ our
    backend's NIP `code`, so Mono shows its own bank picker. Our
    `bank_selection_screen` list is therefore a browse/entry surface; tapping any
    bank just opens Mono's picker (minor double-pick). To skip Mono's picker
    later, map our `/banks/available` entries to Mono institution ids.
  - **iOS:** added `NSMicrophoneUsageDescription` to Info.plist (camera already
    present); Android camera permission already present.
- **⚠️ Dependency bump:** `mono_flutter` needs `js ^0.7.1`, which conflicted with
  `flutter_secure_storage ^9.2.2`. Upgraded **flutter_secure_storage → ^10.0.0**
  (pulls in `webview_flutter`). v10 auto-migrates v9 data to new ciphers on first
  read (no re-login expected); removed the now-ignored
  `AndroidOptions(encryptedSharedPreferences: true)` flag. minSdk must be ≥23
  (already satisfied via Firebase).
- **`bank_linking_success_screen`** → accepts `BankModel` (not `String`); shows
  real bank name + masked account number from the API response. Router updated.
- **`my_accounts_screen`** → `ConsumerWidget`; loads from `linkedBanksProvider`
  with skeleton; empty state unchanged. Each account tile opens
  `showBankAccountActionsSheet` (new widget) with **Sync** (`POST /banks/{id}/sync`)
  and **Disconnect** (`DELETE /banks/{id}`) buttons, each with loading state.
  Disconnect updates local state optimistically via the notifier.
- **`bank_account_actions_sheet`** (new) — modal sheet showing bank header +
  sync (outline) + disconnect (danger) action buttons.
- `flutter analyze` clean.

### 2026-06-29 — Endpoint sync vs live OpenAPI (additive: 4 new client endpoints)
- Diffed `docs/API.md`/`api_endpoints.dart` against live `https://api.finclarai.com/openapi.json`
  (title now "Finclair AI 1.0.0"). **All existing contracts unchanged** — purely additive.
- **New client-facing endpoints** documented + added to `ApiEndpoints` (paths only, not yet
  wired in any repo/provider):
  - `GET /income/calculate` → `IncomeCalculationDto {monthly, annual, weekly, daily}` (numbers, no params).
  - `PATCH /income/{income_id}` → body `{amount}` (number|string), amount-only update by id.
    (Note: bare `PATCH /income` for full-record update still exists too.)
  - `GET /banks/{bank_id}/balance` → `ApiResponse<dict>` (linked-account balance).
  - `GET /budgets/{budget_id}/insight` → `ApiResponse<string>` (per-budget AI insight, sibling of `/insights/home`).
- **Internal/service-only (NOT for the app)**: `POST /email/enqueue`, `GET /email/jobs/{job_id}`
  — both require an `x-api-key` header. Documented under a new "Internal / Service-Only" section
  in `docs/API.md`; deliberately **not** added to `ApiEndpoints`.

### 2026-06-22 — Budget API changed (verified against live OpenAPI) + code synced
- Diffed `docs/API.md` against the live spec (`https://api.finclarai.com/openapi.json`).
  The budget contract had drifted from what we'd documented/built:
  - **`POST /budgets`** now takes **only `amount_allocated`** — `name`, `start_date`,
    `end_date` are gone (backend assigns dates = current month). `amount_allocated`
    accepts a **number or numeric string**.
  - **`PATCH /budgets/{id}`** now takes **only `amount_allocated`** (the lone mutable field).
  - **`BudgetResponseDto` dropped `name`** entirely. `start_date`/`end_date` always present.
  - **`AllocationResponseDto` gained `category_icon`** (nullable string).
  - **`DELETE /budgets/{id}`** now returns `ApiResponse<dict>` (was documented as the budget).
- Updated `docs/API.md` (endpoint bodies + `BudgetResponseDto`/`AllocationResponseDto`
  schemas + a dated ⚠️ note in the Budgets section).
- Synced the code I'd written 2026-06-19 to match: `BudgetModel` dropped `name`;
  `AllocationModel` added `categoryIcon`; `BudgetRepository.createBudget`/`updateBudget`
  send only `amount_allocated` (removed the `_dateOnly` helper + name/date args);
  `BudgetNotifier.create({amountAllocated})` simplified; `create_budget_screen` no longer
  fabricates a name/start/end. `flutter analyze` clean.
- Note: `category_icon` from the API is **not yet used** — the tile still derives icon/color
  from the category *name* via expenses' `expenseCategory*` utils. Wire the backend icon
  string later if/when we have a name→IconData map.

### 2026-06-19 — Receipt scanning: dual path (OpenAI ⇄ backend), config switch
- Added `core/config/ai_config.dart` → `AiConfig.receiptScanSource`
  (`ReceiptScanSource.openai | .backend`); flip the const (or
  `--dart-define=RECEIPT_SCAN_SOURCE=backend`) to choose the implementation.
- `expense_ocr_screen` (now `ConsumerStatefulWidget`) branches in `_runOcr`:
  - **openai** → `ReceiptAiService.scanReceipt` → review screen (`scannedExpense`), edit then save.
  - **backend** → `expenseListProvider.notifier.scanReceipt(file)` → `POST /expenses/receipt`
    (creates the expense server-side) + list refresh → opens `expenseDetail` of the created expense.
- Added `ExpenseListNotifier.scanReceipt(File)` (uploadReceipt + refresh).
- OpenAI key: restrict to **Model capabilities = Write**, everything else None; set a project
  usage cap on the OpenAI dashboard.

### 2026-06-19 — Receipt scanning: ML Kit OCR → OpenAI vision
- Removed on-device OCR: deleted `core/services/ocr_service.dart` and dropped
  `google_mlkit_text_recognition` from pubspec. `image_picker` stays (camera capture).
- New `core/services/receipt_ai_service.dart` — `ReceiptAiService.scanReceipt(File)` returns
  the same `ScannedReceiptModel`, so `expense_ocr_screen` + scanned-expense flow are unchanged.
  Base64-encodes the photo, calls OpenAI `/chat/completions` (model `gpt-4o-mini`,
  `response_format: json_object`, vision image_url) on its **own Dio** (different host/auth than
  `ApiClient`), parses strict JSON into merchant/total/items[name,qty,unit_price,amount,category].
- **Key handling:** `AppConstants.openAiApiKey/openAiModel/openAiBaseUrl` via
  `String.fromEnvironment` → pass at build time: `--dart-define=OPENAI_API_KEY=sk-...`
  (and optional `OPENAI_MODEL`). Empty key → service throws → screen shows its failed state.
- **Security caveat (in code comments):** a key compiled into a mobile binary is still
  extractable — dev/MVP only; should move to a backend endpoint (`POST /expenses/receipt`
  exists, `uploadReceipt` already wired) before production.

### 2026-06-19 — Social login native config: Google live (iOS+Android), Apple deferred
- **Google sign-in fully configured and testable on both platforms:**
  - Enabled the **Google** provider in the Firebase console (auto-created OAuth clients).
  - Re-downloaded `ios/Runner/GoogleService-Info.plist` (now has `CLIENT_ID` +
    `REVERSED_CLIENT_ID`). Added the reversed-client-id URL scheme to `ios/Runner/Info.plist`
    (`CFBundleURLTypes`). Ran `pod install` (firebase_auth/google_sign_in pods linked).
  - Android: registered the **debug** SHA-1 (`30:8A:79:…:37:E0`) + SHA-256 in Firebase,
    re-downloaded `android/app/google-services.json` (now has `certificate_hash` + an
    Android OAuth client). **Release/upload-key + Play App Signing fingerprints still TODO**
    before a Play Store build. Debug keystore: `~/.android/debug.keystore` (alias
    `androiddebugkey`, storepass `android`); read it with Android Studio's bundled keytool
    (`/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool`) since system
    `java`/`gradlew signingReport` has no JRE.
- **Apple sign-in coded but hidden + reverted entitlement wiring:** added
  `ios/Runner/Runner.entitlements` (`com.apple.developer.applesignin = [Default]`) and
  initially set `CODE_SIGN_ENTITLEMENTS` on all 3 Runner configs — but a device `flutter run`
  failed because the project's team is a **free Personal team** (no Sign in with Apple), which
  broke ALL iOS device builds. **Removed the `CODE_SIGN_ENTITLEMENTS` refs** to unblock builds;
  the entitlements file stays as a dormant artifact. Button gated by
  `const kAppleSignInEnabled = false` in `sign_up_screen.dart` (Google goes full-width while
  hidden). Blocked on a paid Apple Developer account we control — see Open threads.
- Also noted on this device build: `google_mlkit_text_recognition` (OCR) pods don't support
  arm64 **simulator** on Apple-Silicon iOS 26+ — OCR must be tested on a **real device**.
- `flutter analyze` clean. Email/passcode auth unaffected.

### 2026-06-19 — Budget flow wired to live `/budgets` API
- Previously the whole budget feature ran on hardcoded mock data. Now wired end-to-end.
- New `budget_model.dart` (`BudgetModel` + nested `AllocationModel`). Money fields parsed
  as **numbers** (per API note). Computed getters: `unallocated`,
  `totalAllocatedToCategories`, `daysLeft` (from `end_date`).
- New `BudgetRepository` — `getBudgets`/`getBudget`/`createBudget`/`updateBudget`/
  `deleteBudget` + allocation `upsertAllocation` (PUT) / `deleteAllocation` (DELETE).
  Dates sent as `YYYY-MM-DD`. Endpoints already existed in `ApiEndpoints`.
- New `budget_providers.dart`: `budgetProvider` (`AsyncNotifier<BudgetModel?>`) loads the
  current budget (first of `GET /budgets`); exposes `create`/`updateAmount`/`allocate`/
  `removeAllocation`/`delete`/`refresh`. `budgetRepositoryProvider` for the repo.
- `budget_screen.dart` → `ConsumerWidget`; `state.when` renders skeleton / error+retry /
  empty / filled. Filled state maps `allocations` → `BudgetCategoryItem` via expenses'
  `expenseCategory*` utils; chart + Clara insight built from real data. Allocate flow
  calls `allocate(categoryId, amount)`; budget-details delete calls `delete()`.
- `create_budget_screen.dart` → `ConsumerStatefulWidget`; Continue creates a budget
  (auto name "`<Month> Budget`", current-month start/end) or, when launched with the
  `'Increase budget'` title, calls `updateAmount`. Button shows `isLoading`.
- `budget_category_sheet.dart` now loads **real categories** (`categoriesProvider`,
  reused from expenses) with a skeleton; returns a `CategoryModel`. `budget_allocation_sheet`
  returns a `BudgetAllocationResult{category, amount}` instead of `void`.
- `BudgetCategoryItem.entries` made nullable (API has no per-allocation entry count);
  removed the old `defaultBudgetCategories` mock list.
- **Open thread:** `budget_add_category_sheet` (custom category create) and the
  per-category tile tap (`_onCategoryTap` just re-opens the picker) are still UI-only —
  no edit/remove-allocation flow wired from the tile yet. Currency in
  `BudgetSummaryCard`/`BudgetCategoryTile` is still hardcoded `₦` (pre-existing).

### 2026-06-19 — Social login (Google + Apple) wired through `/auth/social`
- Wired the previously-dead Google/Apple buttons on `sign_up_screen.dart`.
- New `SocialAuthService` (`core/services/social_auth_service.dart`) — wraps
  `firebase_auth` + `google_sign_in` + `sign_in_with_apple`; returns a Firebase ID
  token (`SocialAuthResult`: success/cancelled/failed). UI/providers never touch the
  SDKs directly (same pattern as `BiometricService`).
- `AuthRepository.socialAuth({firebaseToken, defaultCurrency})` → `POST /auth/social`,
  returns `TokenPairModel`. Endpoint already existed in `ApiEndpoints.socialAuth`.
- New `socialAuthProvider` (`Notifier<SocialAuthState>`) — per-provider loading flag
  drives each button's `isLoading`; on success replays the login flow
  (`clearUserScopedDataRef` → `authStateService.logIn` → `userProfileProvider.fetch`);
  cancelled is silent; failures surface via `AppSnackbar.error` through a `ref.listen`.
- Added packages: `firebase_auth ^5.3.4`, `google_sign_in ^6.2.2`,
  `sign_in_with_apple ^6.1.3` (approved). Fixed `AppStrings.apple` casing ('apple'→'Apple').
- **Not runnable yet** — needs Firebase console + native config (see Open threads).

### 2026-06-19 — Home dashboard wired to live data + shimmer
- **`GET /expenses/summary` and `GET /insights/home` now wired in-app** (previously docs-only).
  - New model `expense_summary_model.dart` (`ExpenseSummaryModel` + nested `CategorySummaryModel`,
    `MonthlyTrendPointModel`, `IncomeExpenseTrendPointModel`). All money fields parsed as numbers.
    `ExpenseSummaryModel.balance` = `monthlyIncome - totalExpense`.
  - `ExpenseRepository.getSummary({year, month})` + `getHomeInsight()` added.
  - New providers in `home/providers/home_dashboard_provider.dart`: `homeSummaryProvider`
    (FutureProvider) + `homeInsightProvider`.
- **Home widgets refactored to self-fetch + render their own skeleton** (each section loads
  independently per `CLAUDE.md §8`):
  - `BalanceCard` → shows `summary.balance`; shimmer while loading. Now a `ConsumerWidget`
    (dropped the unused hide-balance toggle/props).
  - `SpendingCard` → `summary.totalExpense` + % of income bar; shimmer; empty when no expense.
  - `IncomeExpenseChartSection` → driven by `incomeExpenseTrend`; **keeps optional
    `data/totalIncome/totalExpense` overrides** so `budget_screen` still passes mock data.
  - `ClaraCard` → `homeInsightProvider`; shimmer; keeps `insightText` override (budget screen).
  - `RecentExpensesSection` already wired (unchanged).
- `HomeScreen` simplified: dropped all mock balance/`isEmpty` plumbing for these cards, added
  pull-to-refresh that invalidates summary/insight + refreshes the expense list.
- **Budget section on home still mock** — `budget` feature has no data/providers layer yet
  (empty `data/` + `providers/` dirs); left `BudgetSection(isEmpty:)` as-is.
- **Fixed: previous user's data leaking across logout→login.** New
  `core/services/session_reset.dart` invalidates all user-scoped data providers (home summary,
  insight, income, income sources, expense list, expense categories) + resets `appConfig`
  (currency/categories) to defaults. Auth/credentials are intentionally NOT cleared (so re-login
  is easy — handled by `authStateService`). Called on **logout** (`logout_sheet.dart`, WidgetRef
  variant) AND on **login + verify-email success** (`login_provider`/`verify_email_provider`,
  `clearUserScopedDataRef(Ref)` variant). Login-side clearing is the robust guarantee — logout-only
  clearing can race with the still-valid 15-min access token and repopulate the cache.

### 2026-06-13 — API host change + new endpoints (docs only)
- **Base URL changed:** `finclar-ai.onrender.com` → `https://api.finclarai.com/api/v1`.
  Updated `ApiEndpoints.baseUrl` default + `docs/API.md`. Only one hardcoded reference existed.
- **New live endpoints** (verified against the running API with the test account):
  - `POST /auth/social` — Firebase-token social sign-in → token pair (`default_currency` defaults `NGN`).
  - `GET /expenses/summary?year&month` — `ExpenseSummaryDto`: month total, MoM change, category
    breakdown, `monthly_trend`, `income_expense_trend`. **Money fields are numbers, not strings.**
  - `GET /insights/home` — `ApiResponse<string>`; AI-generated insight sentence for the Clara card.
    There is **no `/ai/chat`** — removed those constants.
  - **Budgets now live:** `GET/POST /budgets`, `GET/PATCH/DELETE /budgets/{id}`,
    `PUT /budgets/{id}/allocations`, `DELETE /budgets/{id}/allocations/{category_id}`.
    `BudgetResponseDto` has computed `spent/remaining/pct_used` + per-category `allocations`.
- Added the new path constants to `api_endpoints.dart`; `docs/API.md` + both checklists updated.
  **Not yet wired in app** (no repos/providers): social auth, expense summary, insights, budgets.
- Open follow-ups: wire spending screen + home charts to `/expenses/summary`; wire budget feature
  (UI already built) to the new CRUD; wire Clara card to `/insights/home`; Firebase Auth for social.

### 2026-06-16 — Expenses API wiring (full)
- **Data layer:** rewrote `ExpenseModel` to mirror backend `ExpenseResponseDto`
  (amount/description/expense_date/source/status/categories[]/items[]/receipt_url) with
  back-compat getters (`name`→description, `category`→first category, `date`, `note`,
  `merchant`=null) so existing widgets compile unchanged. Fixed `CategoryModel` to backend
  shape (id/name/description). New `ExpenseRepository` (list w/ filters, get, create, update,
  delete, uploadReceipt multipart, getCategories) on `ApiClient.getPaginated`/post/patch/delete.
- **Providers** (`features/expenses/providers/expense_providers.dart`): `expenseRepositoryProvider`,
  `categoriesProvider` (FutureProvider), `expenseListProvider` (AsyncNotifier<ExpenseListState>)
  with month filter (start/end from selected month), page-1 load, `loadMore` pagination,
  `setMonth`, `refresh`, and `create`/`edit`/`delete` that patch local state.
- **UI wired with skeletons everywhere:** expenses screen (skeleton on load, RefreshIndicator,
  scroll pagination, FAB → add sheet, month picker → setMonth); category sheet → backend
  categories (returns `CategoryModel`, skeleton rows); edit sheet → Consumer, category UUIDs,
  create/edit via provider with button loading; preview screen → delete via provider w/ overlay;
  home recent-expenses → provider data + skeleton.
- **Mandatory skeleton rule** added to `CLAUDE.md §8` (Loading state rule): every fetch-and-
  display location must show a shape-matching shimmer/skeleton — no exceptions.
- **Known limits / deferred:** summary-card "total" sums only loaded pages (no backend sum
  endpoint); detail screen uses the list's `ExpenseModel` via `extra` rather than re-fetching
  `GET /expenses/{id}`; scanned-receipt screen still doesn't POST to `/expenses/receipt`
  (repo method exists, UI not wired); "View all" on home recent-expenses has no nav target yet.
  `flutter analyze` clean across the whole project.

### 2026-06-16 — User profile: startup load + local caching
- **Bug:** on app restart with a persisted session the profile stayed `null` (Settings +
  Home headers blank) — `userProfileProvider.build()` returned `null` and `fetch()` only
  ran after login/verify.
- **Fix + caching:** `build()` now self-loads when an access token exists. Added a real
  user cache (`StorageService.getCachedUser/saveCachedUser/clearCachedUser`, key
  `userKey`). Flow: `build()` returns the cached `UserModel` instantly (no flicker) and
  refreshes from `/user/me` in the background; every successful fetch re-caches; cache is
  cleared on logout (`AuthStateService.logOut`) and `clear()`. Background-refresh failure
  keeps the cached profile.
- **401 → refresh is already implemented** in `auth_interceptor.dart` (queue-guarded
  concurrent refresh, retries original request, force-logout on refresh failure). No change
  needed there.

### 2026-06-16 — Small unblocked fixes: onboarding goals + biometric login
- **Onboarding goals fixed (was a 422):** added `FinancialGoalModel`, `AuthRepository.getGoals()`
  (`GET /goals`), and a `goalsProvider` (FutureProvider). `preference_screen.dart` now
  renders cards from the fetched goals (loading spinner + retry on error) and submits the
  selected goal's **UUID** to `POST /auth/onboarding/goals`. Card visuals (icon/color) are
  keyed by backend `key` (`smart_money_saving`/`track_my_spending`/`stick_to_a_budget`/
  `feel_more_in_control`); removed the old hardcoded string-key map.
- **Biometric login wired on the login screen** (returning users only). Pattern: there's no
  biometric-token backend, so on a successful passcode login *while biometric is enabled* the
  passcode is saved to secure storage (`biometricPasscodeKey`); on the returning-user passcode
  phase the login auto-prompts biometrics (once) and shows a "Use biometrics" button —
  success replays the stored passcode through `submitPasscode`. `LoginState.canUseBiometrics`
  gates the UI (requires enabled + stored passcode + device available).
- **Security/lifecycle:** stored passcode is wiped + biometric disabled on logout
  (`AuthStateService.logOut`), on "Not my account" (`clearSavedEmail`), and when the Settings
  toggle is turned off. Note: enabling biometric in Settings only takes effect at the *next*
  passcode login (that's when the passcode is captured) — by design, no passcode re-entry UI.

### 2026-06-15 — Firebase wired (manual route) + FCM NotificationService
- Manual Firebase setup (not flutterfire CLI — firebase-tools install blocked by a
  root-owned `~/.npm` cache). Config files added: `android/app/google-services.json`
  and `ios/Runner/GoogleService-Info.plist` (added to Runner target in Xcode). Both
  match bundle/package `com.finclar.finclarAi`, project `finclar-ai`.
- **App IDs unified to `com.finclar.finclarAi`** (camelCase) on both platforms. Android
  `applicationId` changed from `com.finclar.finclar_ai` (Firebase console rejects the
  underscore for the app id); Android `namespace` + Kotlin package left internal as
  `com.finclar.finclar_ai` (not Firebase-relevant, avoids moving dirs). iOS bundle
  unchanged.
- Google Services Gradle plugin wired: `id("com.google.gms.google-services") version
  "4.4.2" apply false` in `android/settings.gradle.kts`, applied in `android/app/build.gradle.kts`.
- `main()` now async: `Firebase.initializeApp()` + `NotificationService.init()` in a
  try/catch so a Firebase failure never blocks launch. No `firebase_options.dart`
  (manual route relies on native config files).
- `core/services/notification_service.dart` — permission request, iOS APNS-token check +
  foreground presentation options, FCM token + refresh, foreground/background/opened
  handlers, `NotificationCategory` enum (transaction/budget/group/aiInsight) + tap
  handler. All logging via `Log`. `_registerToken` is a stub — no device-token endpoint
  in `docs/API.md` yet; wire to `ApiClient` when backend adds one.
- Status: Android push ready in debug (no extra setup). iOS push pending APNs `.p8`
  key upload (Firebase → Cloud Messaging) + Xcode Push/Background-Modes capabilities;
  requires a **paid** Apple Developer account. `flutter analyze` clean; full APK build
  not completed locally (first build downloads the new google-services plugin — slow;
  deferred to user's own `flutter run`).

### 2026-06-15 — Core infra: pagination parser + biometric service
- Rewrote `PaginatedResponse<T>` (`core/api/api_response.dart`) to match the real
  `GET /expenses` envelope: top-level `data: [...]` list + sibling `pagination`
  object (`page, page_size, total, total_pages, has_next, has_prev`). Added
  `ApiClient.getPaginated<T>()` to consume it. `hasMore` kept as alias for `has_next`.
- Added `BiometricService` (`core/services/biometric_service.dart`) over `local_auth`:
  `isAvailable`, `hasEnrolledBiometrics`, `authenticate` (returns `BiometricResult`),
  enable/disable persisted via `StorageService` (`biometricEnabledKey`). Native config
  already present (iOS `NSFaceIDUsageDescription`, Android `USE_BIOMETRIC`); fixed
  `MainActivity` to extend `FlutterFragmentActivity` (required by local_auth, else crash).
- Settings now exposes a **Biometric login** toggle (only shown when device supports
  + has enrolled biometrics; enabling is gated behind a live `authenticate()` prompt,
  state persisted via `BiometricService.setEnabled`) and an **Appearance** row opening
  a `theme_selection_sheet.dart` (light/dark/system → `themeProvider`). Added `value`
  trailing variant to `SettingsRow` and theme icons to `AppIcons`.
- Still not wired: biometric on the **login screen** itself (offer biometric on
  subsequent logins) — only the Settings enable/disable toggle exists so far.

### 2026-06-15 — Core infra: FCM / NotificationService
- Firebase configured via the manual route (no `firebase_options.dart`):
  `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` in place,
  `com.google.gms.google-services` gradle plugin wired. `Firebase.initializeApp()` +
  `NotificationService.init()` called in `main.dart`.
- Hardened `NotificationService` (`core/services/notification_service.dart`): permission
  request, FCM token + refresh listener, background handler, foreground + opened-app +
  initial-message handling. Added `NotificationCategory` enum (transaction/budget/group/
  aiInsight) parsed from message data, and a `setTapHandler` hook for navigation routing.
- iOS: added `UIBackgroundModes` (fetch + remote-notification) to Info.plist; foreground
  presentation options + APNS-token wait in the service.
- **Open:** no device-token registration endpoint in `docs/API.md` yet — `_registerToken`
  only logs; wire to `ApiClient` once backend adds the endpoint. Android heads-up
  foreground notifications would need `flutter_local_notifications` (not added — would
  require package discussion per CLAUDE.md §11). Tap handler not yet connected to a router.

### 2026-06-12 — MEMORY.md created
First memory file for the mobile app. State snapshot above was reconstructed from
`CLAUDE.md`, `pubspec.yaml`, `TODOs.txt`, `graphify-out/`, and the recent git log
(latest commits: logout w/ loading+error handling, gamification slides, OCR expense
scanning + bank linking, group chat UI, subscription management UI, budget
management). No code changes — documentation only.
