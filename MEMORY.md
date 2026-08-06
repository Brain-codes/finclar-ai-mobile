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

**Backend:** `https://api.finclarai.com/api/v1` (Swagger at `/docs`).

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
| `group`        | list, create, detail, friends, group chat, savings, friend invites, **standalone friends screen + invite links** | **Fully wired to live API** (2026-07-06) — friends + groups + members + savings + chat. Friends screen + invite/deep-link flow added 2026-08-06 |
| `subscription` | plans, upgrade, active subscription + cancellation sheets   | **Wired to live `/subscriptions` API** (2026-07-20); Paystack checkout untested against a real key |
| `gamification` | insight slides, "wrapped" recap screens, daily streak card   | **Wired to live `GET /wrapped`** (2026-08-02); converted year-in-review → **monthly recap** (2026-08-03). Daily streak card wired to live `GET /expenses/streak` (2026-08-05) — fires once a day on the first expense logged. Untested on device. |
| `challenges`   | Savings challenges (3 types), entries, badges                | **Wired end-to-end** (2026-08-04) — list/detail/create/edit/cancel/log-entry against live `/challenges/*`. Badges screen reads live `/challenges/badges/*`. All three backend types (`friday_savings`, `no_spend`, `budget_category`) startable from cards on the challenges screen or the `+` picker, each on its own cadence — Friday weekly, no-spend Fri–Sun only, category on a random ~weekly date (2026-08-05). Untested on device. |
| `settings`     | main settings, account/contact tiles, **edit details** (name/username/currency), delete-account sheet | Built; edit-details sheet replaced the single-field name sheet (2026-08-06) |
| `onboarding`   | first-run coachmark tour + quick-start checklist              | **New** (2026-08-06) — `showcaseview` behind `AppCoachmark`. Untested on device. |

## Open threads / known issues

- **Three backend asks are blocking real product scope** (raised 2026-08-06, written up in
  `docs/API.md` → Planned / Not Yet Live): an **income ledger** (today it's one record per
  user, so there's no income history and no second paycheck), **invite by email/phone**
  (`POST /friends/invite` takes only a `recipient_id`, so non-users can't be invited), and a
  **referral field on `RegisterDto`** (without it, auto-completing a friend request after a
  fresh install is impossible on any client). The last one also needs Branch/AppsFlyer on the
  client — Firebase Dynamic Links is dead.
- **Receipt scanning now defaults to the backend** (`AiConfig.receiptScanSource`). If backend
  OCR regresses, `--dart-define=RECEIPT_SCAN_SOURCE=openai` restores on-device scanning —
  but that path ships the OpenAI key in the binary, so it's dev-only.
- **Budget month filter can't cross years.** `showMonthSelectionSheet` returns a month only, so
  the Budget tab's filter is pinned to the currently selected year. Needs a year stepper in that
  sheet (shared with the expenses month picker).
- **`profile_icon` is still unused.** `UpdateUserDto` accepts it and `updateProfile` passes it
  through, but the settings avatar is a hardcoded circle with no picker. Needs a design call.
- **iOS Universal Links unconfigured** — the `finclar://` scheme works on both platforms, but
  `https://finclarai.com/invite/...` only opens the app on Android. iOS needs an Associated
  Domains entitlement (same paid-account blocker as Apple Sign-In / push), and Android's
  `autoVerify` needs `/.well-known/assetlinks.json` served from finclarai.com.

- **Blocked on backend:** the Clara conversation-context / "chat figures aren't saved" copy
  issues (backend/prompt work). ✅ `POST /groups/{id}/members` **is live** as of the
  2026-08-05 spec check — the "404s" note was stale and the stale warning comment on
  `ApiEndpoints.groupMembers` is gone. ✅ The attach-proof-to-existing-expense blocker was
  **resolved 2026-08-03** — `PATCH /expenses/{id}` now takes a receipt.

- ✅ **Done 2026-08-03:** receipt-attach UI (create + edit), push device-token registration
  (+ unregister on logout), and the Savings Challenges **data layer**. See that dated entry.

- ✅ **Done 2026-08-04:** Savings Challenges UI for **Friday Savings only** — the user's call
  was "work on the one the API is available for, the others when the API is available".
  **Superseded 2026-08-05:** the backend now ships `no_spend` and `budget_category`, and the
  data layer supports all three. What's still missing is a *trigger* — nothing in the shipping
  UI starts one of the two new types. See CHECKLIST.md §14.1.

- ✅ **Done 2026-08-04 (part 2):** badges screen wired to `GET /challenges/badges/mine`,
  Friday prompt + real success modal, Gamify gallery gated behind a build flag. See the
  dated entry.

- **Badge/mascot artwork is still missing.** `assets/images/gamification/` is empty.
  Badges now render a tinted-circle + `icon_name` fallback, so nothing is broken, but
  the real art should be exported from Figma as
  `assets/images/gamification/badge_<key>.png` for the 9 catalog keys, plus
  `friday_savings_mascot.png` / `category_budget_mascot.png` / `no_spend_mascot.png`.

- **Backend gaps for gamification (raised with Tolu 2026-08-04, re-checked 2026-08-05):**
  - ✅ **Resolved.** `ChallengeType` is now `friday_savings | no_spend | budget_category`,
    with `target_category_id` + `current_period_spent` on the response. All three are
    supported in the app's data layer as of 2026-08-05.
  - ✅ **Resolved (2026-08-05, second re-check — Tolu shipped it).** `GET /expenses/streak`
    is live and wired. It is a *daily* streak, distinct from a challenge's `current_streak`,
    which counts weeks. `streak_card_modal.dart` now runs on real data.
  - No monthly badge-summary endpoint; the app groups `badges/mine` by `earned_at`
    client-side. `earned_period` is a week label on some badges, so it isn't groupable.

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
  in Xcode, and a **paid** Apple Developer account. The client side is **done** as of
  2026-08-03 — `NotificationService.registerToken()` POSTs `/notifications/device-tokens`
  after login and logout sends `device_token`. Only the iOS APNs setup remains.
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

### 2026-08-06 — Firebase distribution wired into GitHub Actions

Fastlane was only ever run by hand — there was no CI workflow for releases (the only
two workflows were the FLOWS.md doc sync/guard). Added
`.github/workflows/release.yml`: triggers on push to `main` (docs/markdown-only pushes
excluded) plus manual dispatch with `bump` / `skip_git` inputs, and calls
`bundle exec fastlane beta skip_ios:true`. The workflow is deliberately a thin runner —
all version/build/upload/tag/push logic stays in `fastlane/Fastfile`.

- No infinite loop: the lane's release commit carries `[skip ci]`, which GitHub honours.
- `fetch-depth: 0` is required — the bump is derived from commits since the last `vX.Y.Z` tag.
- Secrets needed: `FIREBASE_SERVICE_ACCOUNT_JSON`, `ENV_JSON`, `ANDROID_KEYSTORE_BASE64`
  + the three keystore password/alias secrets. App IDs and tester groups are *not*
  secrets — they live in the committed `fastlane/.env.default`.
- **Bug fixed along the way:** the Fastfile's `flutter build apk/ipa` never passed
  `--dart-define-from-file=env.json`, so every distributed build shipped with an empty
  `OPENAI_API_KEY` / `MONO_PUBLIC_KEY`. Added a `dart_defines_flag` helper that applies
  it when `env.json` exists (absent on a fresh clone, so it degrades instead of failing).
- iOS is skipped: it needs a macOS runner + signing certs. When enabling it, keep it in
  the **same job**, not a parallel one — the umbrella `beta` lane bumps the version once
  and cruises both platforms, so two jobs would compute two different versions.
- Docs: new `docs/RELEASE_PIPELINE.md` §5 (old §5 renumbered to §6).

### 2026-08-06 — Clara chat renders backend markdown

Clara's replies come back as markdown (`**bold**`, numbered lists, `\n\n` paragraph
breaks) and were being dumped into a single `Text`, so users saw literal asterisks
and one run-on wall of text. New `clara_markdown.dart` parses headings, numbered and
bulleted lists, bold, italic and inline code into styled blocks.

Deliberately hand-rolled, not a package: the typewriter reveal truncates the
*rendered* output, whereas any markdown package fed a truncated raw string shows
`**Track Inco` until the closing fence lands, then reflows. `flutter_markdown` is
also discontinued. If Clara ever emits tables/links/code fences, switch to
`gpt_markdown` and drop the reveal to a fade.

`claraRevealDuration(String)` now has a sibling `claraRevealDurationFor(int)` — the
bubble and the insight-card delay both time off the markdown-stripped glyph count
(`claraPlainLength`) so the chart still lands exactly when the text finishes.

`CLAUDE.md` §11 package rule rewritten: recommend a package out loud when it's
genuinely better instead of reflexively hand-rolling, and always wrap it.

### 2026-08-06 — `docs/FLOWS.md` + auto-sync to Google Docs

New user-facing flow guide at `docs/FLOWS.md` — 50 flows across 12 sections covering
every screen, sheet and entry point in the app ("how do I add an expense / change my
username / check my badges"). Written in the `/test-guide` house style: numbered
walkthroughs, second person, exact labels bolded, exact copy quoted, cancel paths
included, and real assertions where a derived number should move. Scraped from the
code (routes, screens, sheets, snackbar/empty-state copy), not from memory.

Sections 10 and 11 are lookup tables — plan limits, and every error/empty state with
its exact copy and the way out.

**Sync:** `.github/workflows/sync-flows-doc.yml` fires on any push to `main` touching
`docs/FLOWS.md` and runs `scripts/sync_flows_to_gdoc.py`, which converts the markdown
to HTML and overwrites the body of the shared Google Doc
(`1-q1W4-9fvVHO_rRW-PPnGhn-8owmeXLSRO5W0RSQiic`) via a Drive `files.update` media
upload. Drive converts the HTML back to native Docs content, so the doc keeps its ID,
URL and comments. One-way and destructive to the Doc — edits made directly in Google
Docs get overwritten, and the auto-appended footer says so.

Needs repo secret `GOOGLE_SERVICE_ACCOUNT_JSON` and repo *variable* `GOOGLE_DOC_ID`,
plus the Doc shared as Editor with the service account's `client_email`, plus the
Drive API enabled on the same GCP project the key belongs to (`Finclar Ai`,
project 1092747272049 — this was the first failure: `403 accessNotConfigured`).

**Drift guard:** `.github/workflows/flows-doc-guard.yml` fails a PR (or a direct push
to main) that touches `lib/features/**/presentation/**`, `lib/app/routes/**`,
`lib/shared/widgets/**` or `app_strings.dart` without also touching `docs/FLOWS.md`.
Escape hatches: the `no-flow-change` PR label, or `[skip flows]` in a commit message.
It only catches omissions — it can't write the doc.

**Rule:** `CLAUDE.md §0b` now requires updating `docs/FLOWS.md` in the same change as
any flow change, and defines what counts as one (new screen/route/entry point, a
button or step added/removed/reordered, any user-visible copy change, a confirmation
gained or lost). Considered and rejected for now: `anthropic/claude-code-action` in CI
to regenerate the doc from each diff — costs tokens per run, wants review anyway.

### 2026-08-06 — Budget month roll-over: stale-month bug + previous-month summary

Reported as "I'm in August with no August budget, but the Budget tab shows July" — it read as a
data bug, it was a fallback. `BudgetNotifier._loadCurrent` did
`firstWhere(month == now.month, orElse: () => _all.first)`, so with no budget for the current
month it silently rendered whatever budget happened to be first in the list, fully labelled as
if it were the current month.

- **Provider reshaped.** `budgetProvider` is now `AsyncNotifierProvider<BudgetNotifier, BudgetState>`
  (was `BudgetModel?`). `BudgetState` carries `budget` (selected month, **never** back-filled from
  another month), `previous` (most recent budget strictly before the selected month),
  `month`/`year`, and `hasAnyBudget`. Selection is remembered in the notifier so
  allocate/delete/refresh no longer snap the view back.
- **`_all` is now maintained.** `allocate`, `removeAllocation`, `updateAmount` and `delete` used to
  mutate `state` only, leaving the cached list stale — switching months resurrected deleted
  budgets. All mutations go through `_upsert` / an explicit `removeWhere` + `_resolve()`.
- **`create` jumps the view** to the month the backend stamped the new budget with.
- **New `BudgetPreviousMonthCard`** (`presentation/widgets/`) — collapsible carry-over summary
  shown above the empty state when the selected month has none. Collapsed: remaining, progress
  bar, spent/total, % used. Expanded: full breakdown + per-category allocations.
- **Empty state is month-aware** — "No budget for August" when you've budgeted before, plain
  "No budget yet" on a truly first run.
- **Month filter is now discoverable.** A permanent funnel pill (icon + short month, e.g. `Aug`)
  sits in the header in every state; the summary-card month chip gained a chevron. Previously the
  only way to change month was tapping an unmarked chip that vanished with the empty state.
- **Second `Create budget` entry point** — a labelled orange pill at the top right whenever the
  selected month has no budget (deliberately labelled, not a bare `+`).
- **`BudgetSummaryCard` no longer hardcodes `₦`** — takes `currencySymbol` and uses
  `formatCurrency`. It had two private hand-rolled formatters with the symbol baked in.
- `quick_start_card` now checks `hasAnyBudget`, so the onboarding checklist doesn't un-tick the
  budget step when the month rolls over.
- Month names/date labels moved into `budget_month_utils.dart` (were duplicated private helpers).

**Known limitation:** `showMonthSelectionSheet` is month-only, so the filter stays within the
selected year — you can't browse to Dec of last year. The previous-month *card* crosses years fine
(it sorts on `year * 12 + month`). A year stepper in that sheet is the follow-up.

`docs/FLOWS.md` §4.1, §4.5, new §4.6 and the §11 empty-state table updated.

### 2026-08-06 — Profile avatars: a Flutter port of react-nice-avatar

`profile_icon` existed end-to-end on the backend (`PATCH /user/me`, `UserResponseDto`) and on
`UserModel`, but **nothing in the app read or wrote it** — every avatar in the UI was initials
or a placeholder icon. The user wanted the same shape as expense categories: store a *name*,
resolve it to artwork at render time.

**There is no Flutter port of [react-nice-avatar](https://github.com/dapi-labs/react-nice-avatar)
on pub.dev**, so one was written and now lives in its own repo:
**https://github.com/Brain-codes/nice_avatar**. This app consumes it as a `git:` dependency
**pinned to `ref: v1.0.0`** — deliberately, so a push to that repo's `main` cannot silently
change every user's avatar. Bump the tag here when you want the change. Not on pub.dev.

**How the port works.** Each part's original SVG is kept verbatim as a string and rendered with
`flutter_svg`; the React components' CSS percentage positioning is reproduced by `PartBox`
(fractional left/right/top/bottom + width/height, resolved against the parent). Nothing was
redrawn by hand, so the artwork is pixel-faithful. `genConfig` reproduces the original's seeded
selection exactly — same 32-bit string hash, same `avoidList`/`usually` weighting — so a given
seed yields the same face in Flutter as on the web. Secondary shades (hoody panel, mohawk
highlight) use the same CIE L\*a\*b\* lightening curve as chroma-js `brighten`, ported in
`colors.dart`.

**The string contract — this is the important bit.** `configFromString(value)` accepts either:
- a **preset id** (`avatar_3`, or any string at all — a username, a user id) → used as a seed;
- an **encoded config** (`nav1.man.F9C9B6.big.…`, from `ResolvedAvatarConfig.encode()`) → exact.

So presets and fully-customised avatars share one `varchar` column and one render path, and
you can move between them without a migration. The backend's existing `avatar_3` example
already works unchanged.

**App side.** New `AvatarPickerScreen` at `RouteNames.settingsAvatar`, reached by tapping the
avatar in `SettingsProfileHeader` (which now shows an edit badge). Two tabs: a 24-preset grid,
and a full customiser (`AvatarCustomiser` + `AvatarOptionRow`/`AvatarColorRow`) covering every
part. Picking a preset stores its id; customising stores the encoded config. `AppProfileAvatar`
is the one wrapper the rest of the app uses — it falls back to `AppAvatar` initials when
`profile_icon` is null, so nothing regresses for existing users. Wired into the settings header
and the home header.

**Gotchas found while building**
- **`pumpAndSettle` never quiesces on a grid or column of `SvgPicture`s** — decoding keeps
  scheduling frames, so the test sits until its 10-minute timeout. Use a fixed number of
  `pump()`s. Screenshot-only tests were used to verify all of this and then deleted: they
  assert nothing, and a non-asserting 10-minute test in the suite is a liability.
- Hair options are hidden when a hat is selected: the original hides hair entirely under a hat,
  so those controls would change something invisible.

**Follow-up, same day — the three open items closed:**

1. **Server-side rendering** — package **v1.1.0** adds `avatarToSvgString()` /
   `NiceAvatar.toSvgString()`: the whole avatar as one self-contained SVG document with no
   dependency on the widget layer, so the backend can render the exact same face for emails,
   OG images or a `/avatar/{id}.svg` route. Verified pixel-identical to the widget output.
   ⚠️ **Layers are placed with `<g transform>`, not nested `<svg>` viewports.** The first cut
   used nested `<svg preserveAspectRatio>` — correct SVG, but flutter_svg drops nested
   viewports entirely, which rendered as coloured circles with no faces. The transform
   resolves to exactly what `xMidYMid meet` / `BoxFit.contain` do and works everywhere.
   Nothing on the backend uses this yet — it is the tool, not the feature.
   (App pins **v1.1.1**; v1.1.0 shipped with a preview test that asserted nothing and hung
   `flutter test` for its full 10-minute timeout, so it was removed.)
2. **Friend / group / chat avatars** now render generated faces instead of initials. Because
   `profile_icon` is returned **only by `/user/me`**, other people's faces are *seeded from
   their username* — stable and distinct, but **not the avatar they actually chose**. Seeding
   deliberately uses the name and not an account id: it is the one identifier every call site
   has, so the same person looks the same in the friends list, the member list and the chat
   thread. `FriendshipModel.friendProfileIcon` and `GroupMemberModel.profileIcon` are already
   parsed, so the real avatars appear with **no client release** the moment the backend sends
   them — that is now ask #4 in `docs/API.md` → "Asked for, not yet built".
3. **Edit-details sheet picks an avatar too.** Two sections, shared with the picker screen via
   `AvatarChoiceSections`: **Recommended for you** — eight faces seeded from the account id, so
   they are personal and stable — and **Presets**, the shared 24. The sheet renders them as
   compact horizontal strips; the full screen uses grids. A recommended pick is stored as an
   encoded config (its seed is derived from the account id and would mean nothing to anyone
   else); a preset is stored by name. `EditProfileResult` gained `profileIcon`.

**Still open**: nothing on the backend consumes the SVG export yet, and other users' avatars
stay generated until `profile_icon` ships on the friends/groups payloads.

### 2026-08-06 — Trello batch: income, onboarding tour, edit details, OCR errors, friends, invites

Six board items. The **live OpenAPI spec was pulled first (77 paths)** because three of them
turned out to be capped by what the backend ships. Those caps are written up as backend asks
in `docs/API.md` → "Planned / Not Yet Live"; read that before re-planning any of this.

**The three constraints, because they explain why the work looks smaller than the cards:**
1. **Income is one record per user.** `GET/POST/PATCH /income` all operate on a single
   `IncomeResponseDto` — no list endpoint, no per-entry create. So "Add Income" ships as
   *set/edit your income*, not a ledger. User's explicit call.
2. **`POST /friends/invite` takes only `recipient_id`** (a UUID) — you can only befriend
   someone who already has an account. No invite-by-email/phone exists.
3. **Deferred deep-linking has no free path.** Firebase Dynamic Links is shut down. Auto-
   completing a friend request *after a fresh install* needs Branch/AppsFlyer **and** a
   backend referral field on `RegisterDto`. Not built — the rest of the invite flow is.

| Task | What changed |
|---|---|
| **1 — Add income** | The only way into income was `home_screen.dart`'s listener, which fires *only when income is null* — once set, there was no route back, and `IncomeNotifier.save()` / `IncomeRepository.updateIncome()` were **dead code**. Now there are **four** ways in, because the modal is the one thing you can't rely on: an action **on the balance card itself**, top-right (a solid white "Add income" button when none exists — it *is* the next thing to do; once income is set it collapses to a bare pencil icon, since the card's job is the balance, not a standing CTA), a row in the `+` sheet (retitled `Add expense` → `Add`), the tappable income legend row on the home chart, and the quick-start card. Every label flips **Add ↔ Update** off `incomeProvider`, since the single-record backend means the second visit is always an edit. The balance-card pill is the answer to "what if the popup doesn't show" — always visible, loud only when income is missing.

**The income screen was also rebuilt.** Title, amount and keypad were fighting for space via two `Flexible(SizedBox())` spacers that collapsed on shorter devices. Now: a fixed title block (with a new subtitle), the amount block getting the entire middle via `Expanded` + `Center`, then the keypad — so there is always air between the three regardless of device height. Added an **amount-in-words pill** under the figure (`core/utils/number_to_words.dart`, 9 unit tests) — reserved-height + `AnimatedOpacity` so the layout doesn't jump when the first digit lands. Also fixed **`AppKeypadController`'s hardcoded ₦** — it now takes a `symbol`, fed from `currencySymbolProvider`, so a USD user stops seeing naira on the keypad. `income_setup_screen` prefills from `incomeProvider` and titles itself "Edit income", and `income_details_sheet` branches `save()` (PATCH) vs `create()` (POST) — activating the dead path. New `AppKeypadController.setAmount()` for the prefill. Home insight + summary are invalidated after a save. |
| **2 — Onboarding** | New `features/onboarding/`. `showcaseview` added, wrapped in `shared/widgets/app_coachmark.dart` so feature code never imports it (CLAUDE.md §3/§4 convention). 6-step tour: balance card → `+` → Expenses → Budget → Groups → Clara FAB — **all six are on screen simultaneously** (home body + shell nav bar), so it runs start-to-finish in one sitting and never navigates mid-flow. Every tooltip carries **Skip** and **Next**. Plus a `QuickStartCard` on home (set income / log first expense / create a budget) that ticks itself off from existing providers and vanishes at 3/3, and a "Start app tour" row in Settings for testing. |
| **3 — Edit details** | `edit_username_sheet.dart` didn't exist — it had already become `edit_preferred_name_sheet.dart` (2026-08-02), editing one field. Replaced with `edit_profile_sheet.dart`: preferred name, username (debounced `GET /user/check-username`), and email rendered **read-only** — `UpdateUserDto` has no email field. Only changed fields are PATCHed. **Currency editing is deliberately off** — the app is naira-only for now (user's call). `currency_selection_sheet.dart` and `AppConfig.supportedCurrencies` are built and working but **not wired to anything**; drop the picker back into the sheet when multi-currency is turned on. |
| **4 — OCR errors** | Two separate bugs. (a) `AiConfig.receiptScanSource` **defaulted to `openai`** — scans never hit the backend, which is why Tolu's messages were never seen. Default flipped to `backend`; `--dart-define=RECEIPT_SCAN_SOURCE=openai` goes back. (b) The exception was caught and discarded — `_FailedSubtitle` hardcoded the generic line. Message now threads through `_failureMessage` state. Also: `ReceiptAiService` no longer flattens every `DioException` into one string, and `api_client.dart`'s 413 branch prefers the backend's wording. Deleted dead `scanning_dialog.dart`. |
| **5 — Add friends** | **Not broken — incomplete.** `GET /friends/search` is live and the repository calls it correctly; "No search result" was genuine. The real gaps: nothing said *what* it searches, and **`POST /friends/invite` was never called from any UI** — `friendsProvider`/`friendInvitesProvider` existed but were consumed only by `session_reset.dart`. Sheet rewritten onto `showAppSheet` + `AppTextField` (it was a raw `showModalBottomSheet` + raw `TextField`, against §8), with an `AddFriendMode` param so the group flow is untouched. New `friends_screen.dart` + `RouteNames.friends` off the Groups header: friends list, **pending-invite inbox with accept/decline**, invite CTA. Empty search now offers "Invite to finclar". |
| **6 — Invites** | `share_plus` + `app_links` added. `InviteService` owns the link shape (`https://finclarai.com/invite/<username>`) and every channel — nothing else builds an invite URL. New `invite_friend_sheet.dart` (WhatsApp / SMS / Email / More), each falling back to the OS share sheet when the target app isn't installed. `DeepLinkService` parses incoming links, and **parks the invite in storage when logged out**, replayed from `AuthStateService.logIn` — the single choke point every auth path already uses. `InviteLinkListener` in the shell opens the pre-filled sheet. Also finally wired `share_group_sheet.dart`, whose share icons were **decorative with no `onTap`**. |

**Decisions worth remembering**
- ⚠️ **The tour flag is "pending", not "seen" — do not invert this.** The first cut keyed off
  an unset `tourCompletedKey`, which meant *every existing user* got ambushed by the tour
  mid-session on the release that introduced the key. It is now
  `AppConstants.tourPendingKey`, written **only** by `AuthStateService.logIn(isNewUser: true)`
  and the Settings row. Absence means *don't show it*. Any future first-run flag should follow
  the same shape.
- The tour also refuses to start unless home is the **current** route, and waits
  `AppConstants.animSlow` for the push transition to settle — starting mid-transition put the
  spotlight on the wrong screen ("sitting between two screens"). `HomeScreen.dispose` calls
  `dismissAppCoachmarks()` so navigating away can't leave the overlay painting over the next
  screen.
- The queued flag is consumed **before** the tour runs, so dismissing can't make it reappear —
  same pattern as the Friday challenge prompt.
- Only **one** first-run interruption per session: `_maybeStartTour` waits on income (so it
  can't stack on the income setup modal) and hands off to `maybePromptChallenge` only when
  the tour has already been seen.
- Logout clears the tour flag **and** any parked invite — a different account on the same
  device must get the tour again and must never inherit someone else's friend request.
- `income_details_sheet` re-reads `incomeProvider` after saving and rethrows: `AsyncValue.guard`
  swallows the failure into state, so without that check a failed save navigated home as if
  it had worked.
- Native config added: `finclar://invite` on both platforms, an `autoVerify` App Links filter
  for `finclarai.com/invite` on Android (needs `/.well-known/assetlinks.json` served from the
  site), and `<queries>` entries for the share targets — without those, `launchUrl` fails on
  Android 11+ even when the app is installed. **iOS Universal Links still need an Associated
  Domains entitlement — blocked on the same paid Apple account as Apple Sign-In and push.**

`flutter analyze` clean. `flutter test` 22/23 — the failure is `test/widget_test.dart`, which
is **red on a clean tree** (boots the app without Firebase); verified by stashing.
**None of this has run on a device.**

### 2026-08-05 — Badges screen rebuilt from Figma (`37:6044`)

The `×N` treatment moved from a small corner chip to the design's real thing: a large outlined
number sitting on the shield's tail — white fill, badge-colour outline, Bricolage SemiBold at 19% of
the tile. It now shows on **every** earned badge including `1x`, per the mock. Layout is a 3-per-row
grid (was a horizontal scroller), month header switched to Geist Medium 16 / `textQuaternary` to
match, and the per-tile name label is gone for badges that have a shield — the ribbon already names
them.

**The artwork had to be normalised first.** The three Figma exports were trimmed differently (and
the category badge carried a long soft shadow the others didn't), so `BoxFit.contain` landed each
shield at a different height and there was no stable place to hang the number. They're now
regenerated onto a common 512×512 canvas — opaque art at a fixed size, bottom edge at 86% — in
`assets/images/gamification/badges/`. The originals are untouched; the normaliser lives in the
session scratchpad, not the repo.

**Artwork now resolves by badge *category*, not key.** The live catalog is 21 badges across 7
categories and only 3 have shields, so keying off `key` meant nearly everything fell through to the
tinted-circle fallback — and `friday_savings_goal_reached` fell through anyway because its file had
been saved as `Badge 3.pngbadge_friday_savings_goal_reached.png`. Fallback badges keep a small name
caption so streak badges stay identifiable. `no_spend_weekend` also had the wrong accent (blue);
the design is orange.

### 2026-08-05 — Challenge cadence + the modal that closed itself

Reworked how challenges *arrive*. The picker from earlier today stays behind the `+`, but it's no
longer the main way in — each type now has a window and a card.

**Fixed a bug reported from device:** the intro modal popped itself before running its CTA, so the
amount sheet opened over an empty screen and dismissing it lost the flow (only route back was
Settings → Challenges). `showChallengeModal` callbacks are now `Future<bool>`; the modal stays up,
spins the pressed CTA, and closes only on success or ✕. Backdrop tap and system back no longer
dismiss it.

**Cadence** — `features/gamification/domain/challenge_availability.dart`, 11 unit tests:
- `friday_savings` — always open, prompts every Friday (unchanged)
- `no_spend` — **Fri 00:00 → Sun 23:59 only**, prompts once per weekend, created with
  `end_date` = weekend end so the backend expires it
- `budget_category` — always open, prompts on a **random** date 5–12 days out, rescheduled each fire

`maybeShowChallengePrompts()` replaced the Friday-only call on home and shows at most one modal per
app open. Push routing now reads `challenge_type` and sends each to its own prompt instead of
funnelling everything to Friday.

**Challenges screen** is now Ongoing → Start a challenge → Past challenges. Available types render
as tinted `AvailableChallengeCard`s with a window pill; out-of-window ones stay visible but dimmed
and locked ("Opens Friday"). Finished runs collapse into `PastChallengeGroup` `×N` rows that expand
to the individual cards. Empty-state copy generalised off "Beat the Friday test".

**Second bug found en route:** the Friday prompt grabbed the first active challenge of *any* type,
so it could have recorded a savings entry against a running `no_spend` challenge. Now type-scoped.

Open: no local notification fires when the weekend opens — that push has to come from the backend
(`flutter_local_notifications` isn't a dependency). Full list in CHECKLIST.md §17.5.

### 2026-08-05 — Challenge type picker (all three types now startable)

Closed the last blocked row from the API audit: `no_spend` and `budget_category` had full data
and UI support but nothing in the shipping app could start one.

**Product decision made — the entry point is a type picker sheet on the challenges screen**, not
a second scheduled prompt. A prompt has to earn its moment (the Friday one does, by being tied to
Friday); picking a challenge is a deliberate choice made when the user goes looking. Both start
points — the `+` in the top bar and the empty state's "Start challenge" — now open
`showChallengeTypeSheet`. Types with an active challenge show "Already running" and can't be
picked; the `+` only hides once all three are running.

`no_spend` / `budget_category` route through their finished `showChallengeModal` intro (mascot +
copy + single CTA) into the create form. **Friday skips its intro** — that modal *is* the weekly
save prompt and its CTAs record an entry rather than create a challenge, so reusing it in a
creation flow would have meant either duplicate buttons or a flag that alters its designed layout.

Found and fixed while wiring: live `UpdateChallengeDto` has **no `target_category_id`** (docs
claimed it mirrored `CreateChallengeDto`), so the edit sheet was letting the user re-pick the
capped category and silently dropping it. The row is read-only when editing now.

Detail in **CHECKLIST.md §16**. No challenge UI was redesigned — the picker is a new sheet, and
everything it opens is existing screens.

### 2026-08-05 — Daily streak wired (backend shipped it)

Re-pulled the spec after Tolu said the streak was updated: **77 paths, up from 75 earlier the
same day.** Both new ones are the daily expense-logging streak, which closes the gap logged in
the audit below. Detail in **CHECKLIST.md §15**.

`GET /expenses/streak` returns `current_streak`, `longest_streak`, `last_logged_date`,
`logged_today` and a `days[]` window of `{ date, day_label, logged, is_today }`. It counts
**days**; a challenge's `current_streak` counts **weeks** — they are unrelated numbers and the
two must never be conflated in UI.

New: `expense_streak_model.dart`, `streak_repository.dart`, `streak_providers.dart`. The
provider is invalidated on both expense-create paths (manual + receipt) and added to
`session_reset.dart`, since the streak is user-scoped.

`streak_card_modal.dart` keeps its design exactly — only its inputs changed. The day-label row
and the sparkle-pill row were hardcoded (7 fixed labels, 3 sparkles + 4 circles); both are now
derived from `days[]`, with each unbroken run of logged days collapsing into one pill. Day
labels are rendered verbatim from the backend so the app never disagrees with the server about
where the week starts.

**Trigger is an assumption, not a spec'd behaviour:** it fires on the first expense logged each
day, at most once, gated on `AppConstants.streakModalDateKey`. The backend gives no "celebrate
now" flag. Milestone-only or a home-screen tap target are both one-line changes in
`maybeShowStreakModal`.

`POST /expenses/streak/dev/simulate?days=` is in the dev tools sheet and shows the real modal
with the returned data.

⚠️ `flutter test` is red because of `test/widget_test.dart` — the scaffold smoke test boots the
app without Firebase. It predates all current work and fails on a clean tree.

### 2026-08-05 — Live API audit; all three challenge types supported

Pulled the live OpenAPI spec (75 paths) and diffed it against `ApiEndpoints` **and** real call
sites. Full findings + remaining work live in **CHECKLIST.md §14** — that's the ground truth,
this entry is just the summary.

| What | Detail |
|---|---|
| **Challenge types** | Backend ships `no_spend` and `budget_category` alongside `friday_savings`. `challenge_model.dart` had hardcoded `fromString` to always return `fridaySavings` and `value` to always emit `'friday_savings'`, so both new types were silently collapsed. Enum now carries all three, plus `target_category_id` and `current_period_spent`. |
| **`ChallengeStatus.failed`** | Was missing from the enum and fell through to `active` — a lost challenge rendered as still running. Now parsed and labelled per type. |
| **Duplicate enum** | `challenge_modal.dart` declared its own `ChallengeType` spelling it `categoryBudget` against the backend's `budget_category`. Folded into the model's enum; `friday_challenge_prompt.dart` and the preview gallery updated. |
| **Display** | Spend-based types read "You've spent" / "Spent this period" against a **cap**, not "saved" against a goal. Detail screen hides the manual log-savings CTA for them (backend scores those from logged expenses). Start sheet swaps weekly-target for spend-cap and adds a category picker (reuses `showExpenseCategorySheet`). |
| **Add-button gate** | Was "any active challenge hides it"; now gated on an active `friday_savings` specifically, since that's what the button starts. |
| **Tests** | `test/challenge_model_test.dart` — 7 unit tests on type/status parsing and the spend fields. |

Also: dead `/transactions` constants deleted (that path exists nowhere in the live spec), stale
"members endpoint 404s" comment removed, `POST /notifications/test-push` wired into the challenge
dev-tools sheet, push `NotificationCategory` maps the two new type strings, `docs/API.md` updated.

**Verified clean, no drift:** every response field checked is already modelled (expense summary,
home insight, groups, wrapped, plans, expenses, savings entries); `GET /expenses` uses all ten
spec query params; multipart shapes match. Push-after-logout is already handled — `logout()`
sends `device_token` in `LogoutDto`.

**Left undone on purpose** (needs a product/design call, all listed in §14.2): `GET
/income/calculate`, `PATCH /income/{id}`, `GET /banks/{id}/balance`, and a device-manager screen
for `GET/DELETE /notifications/device-tokens`. And §14.1's last row — nothing in the shipping UI
*starts* a `no_spend` or `budget_category` challenge yet; the creation path works, it just needs
an entry point chosen.

### 2026-08-04 — Badges wired, Friday prompt, Gamify gallery gated

Follow-up to the same day's challenge work, driven by a product brief from the user and a
note from Tolu (backend).

| File | What |
|---|---|
| `screens/badges_screen.dart` | Rewritten off mock data. Watches `myBadgesProvider` + `badgeCatalogProvider`, groups by **month** (current month first), horizontal scroll per month, `Nx` count when a badge is earned more than once that month, tap → `showBadgeDetailSheet`. Locked catalog badges show greyed in the current month only. Skeleton + pull-to-refresh. |
| `widgets/badge_detail_sheet.dart` | New. Big badge, name, description, and the dates it was earned that month. |
| `widgets/badge_widget.dart` | Now keyed by backend badge **key** (`badgeKey`/`iconName`/`category`) rather than a 3-value enum. `BadgeType` kept — its values now carry the real keys — so the gallery modals still work. Missing PNG falls back to a tinted circle + `icon_name` icon. `Nx` count only renders when > 1. |
| `widgets/friday_challenge_prompt.dart` | New. `maybeShowFridayChallengePrompt` — pops **every** Friday regardless of whether last Friday was saved (that's the streak). The once-per-ISO-week guard (`StorageService.getChallengePromptWeek`) only stops it reappearing on repeat app opens within the same Friday. Keeps the mock's two side-by-side CTAs: **Start saving** (uses the usual amount) and **Enter amount** (different amount this week). Both land on the receipt sheet. If no challenge exists, the first save creates it with that amount as the weekly target. Called from `home_screen.dart` post-frame, **after** income resolves so it can't stack on the income setup modal. |
| `widgets/challenge_modal.dart` | Added optional `onStart` / `onEnterAmount` / `ctaLabel`. The mock's **two side-by-side buttons are the real design** — don't collapse them to one. All null = unchanged gallery behaviour. |
| `widgets/challenge_amount_sheet.dart` | Wired for real: returns a `double`, currency prefix + `CurrencyInputFormatter`, autofocus. Fixed its hint, which read "Enter email address". |
| `services/notification_routing.dart` | New. `NotificationService._onTap` was **never assigned** — every push tap in the app went nowhere. Registered in `main.dart`; `challenge` category opens the Friday modal, other categories log a "no route wired" line. |
| `widgets/challenge_success_modal.dart` | Added optional `message` override. |
| `widgets/record_challenge_entry_sheet.dart` | On success, shows the Friday success modal with the **real** amount, currency, and Fridays left in the **current** month (the hardcoded "5k … April" was gallery copy). |
| `constants/app_constants.dart`, `settings_screen.dart` | `showGamifyGallery = bool.fromEnvironment('SHOW_GAMIFY_GALLERY')` — the Gamify row is hidden unless a build passes `--dart-define=SHOW_GAMIFY_GALLERY=true`. Release builds hide it with no code change. |
| `widgets/challenge_dev_tools_sheet.dart` | New. Wraps the backend's two `/dev/` helpers — `simulate-streak?weeks=N` (jumps the streak and fires real badge + push logic) and `send-test-reminder`. Reached from a gear icon on the challenge detail top bar, gated by `showGamifyGallery`. Simulating invalidates challenges, entries and badges, so the badges screen can be tested without waiting real Fridays. |

Decisions worth remembering:
- Badges group by `earned_at`, **not** `earned_period` — that field is a week label
  (`2026-W31`) on streak badges, so it can't key a monthly section.
- Artwork resolves by badge key (`badge_<key>.png`) with a graceful fallback, so dropping
  the real PNGs in later needs zero code change.
- The Friday prompt marks the week as prompted **before** showing, so dismissing it does
  not make it reappear on the next app open.

### 2026-08-04 — Friday Savings challenge wired end-to-end

Built the UI on top of the 2026-08-03 data layer. Scope was the user's call: **only the
challenge type the backend actually ships** (`friday_savings`); the other two mock types
wait for their endpoints.

**New — `features/gamification/presentation/`**

| File | What it does |
| --- | --- |
| `screens/challenges_screen.dart` | List of the user's challenges. Skeleton → empty → filled, pull-to-refresh, active/past split. The header **+** button only appears when there's no active challenge. |
| `screens/challenge_detail_screen.dart` | Summary card (total saved, goal progress, current/longest streak, weekly target), log-savings CTA, entries list with its own skeleton. Edit + cancel actions in the top bar, active challenges only. |
| `widgets/challenge_card.dart` | Streak pill + progress bar + target pill. Progress bar and pill are **hidden when there's no overall target** — the API allows a streak-only challenge. |
| `widgets/challenge_empty_state.dart` | "Beat the Friday test" intro + start CTA. |
| `widgets/start_challenge_sheet.dart` | Create **and** edit (same form). Weekly target required, overall goal optional. |
| `widgets/record_challenge_entry_sheet.dart` | Amount (prefilled with the weekly target), note, and `AppAttachReceiptField` for proof. |
| `widgets/challenge_entry_tile.dart` | Amount + note/verification + date. |
| `widgets/cancel_challenge_sheet.dart` | Confirmation; warns about losing the streak. |
| `widgets/challenge_utils.dart` | `isoWeekLabel` / `hasSavedThisWeek` / `challengeStatusLabel`. |

**Decisions worth remembering**

- `last_entry_week` comes back as an **ISO week label** (`2026-W31`), so `challenge_utils`
  computes the same label locally to answer "have I saved this week?" — that drives both the
  card's status text ("Saved this week" vs "Due this Friday") and whether the detail CTA reads
  "Log this week's savings" or "Log another entry". Any change to that format breaks silently,
  so it's a single helper, not inline logic.
- The detail screen takes the challenge via `extra` but **re-reads the live copy** from
  `challengesProvider` each build, falling back to the passed value. Recording an entry
  refreshes the list, so the streak updates in place without a re-navigation.
- Progress prefers the backend's `progress_percent` and only falls back to
  `totalSaved / overallTarget` when it's null.
- **`challenge_modal.dart` / `challenge_success_modal.dart` were deliberately left untouched.**
  They're the design gallery for all three types and are still wired to
  `gamification_preview_screen.dart`. The real flow uses its own empty state + sheets instead
  of reusing them, partly because their `ChallengeType` enum collides with the model's.
- Routes `RouteNames.challenges` / `.challengeDetail` sit outside the shell (no bottom nav),
  reached from a new "Challenges" row in Settings.

**Also:** migrated `record_savings_sheet.dart` (group savings) onto the shared
`AppAttachReceiptField` — it had a hand-rolled copy of the same row and was **gallery-only**,
so recording group savings now offers the camera too.

`flutter analyze` clean. **Nothing here has run on a device.**

### 2026-08-03 (3rd) — Receipt attach UI, push device tokens, Challenges data layer

Worked the first four items off the post-sync checklist.

**Receipt attach — create *and* edit (checklist items 1 + 4).** New shared
`AppAttachReceiptField` (`lib/shared/widgets/app_attach_receipt_field.dart`): owns its own
camera/gallery source sheet and the picker, parent just holds the `File?`. Extracted as a
shared widget rather than inlined because `record_savings_sheet.dart` has the same row and
should be migrated onto it next (it currently duplicates the markup, gallery-only).
Wired into `edit_expense_sheet.dart` for both paths — so a new expense can be created
already-verified, **and** an existing one can have proof attached, which is what
`evidence_suggested` was always pointing at. Field hides itself once an expense is already
`verified` (nothing left to prove), and its helper text changes to a nudge when
`evidenceSuggested` is true. Stale "display-only" comment on `ExpenseModel.evidenceSuggested`
corrected.

**Push device tokens (item 2).** `NotificationService._registerToken` was a stub; it now
POSTs `/notifications/device-tokens`. Two ordering problems handled:
- `init()` runs in `main()` *before* login, and the endpoint is 🔒 — so `_registerToken`
  no-ops when there's no access token and just caches, and `AuthStateService.logIn` (the
  single choke point for every auth path incl. social) fires `registerToken()` afterwards.
  Not awaited — push must never delay landing on home.
- Registration failure is caught and logged, never surfaced. A push problem must not break
  login.
- `AuthRepository.logout` now sends `{device_token}` so a logged-out device stops receiving
  the previous user's alerts. Chose this over `DELETE /device-tokens/{token_id}` because we
  never persist the returned token id, and the logout body is exactly the intended path.

**Savings Challenges — data layer only (item 3).** Placed in `features/gamification/`, not a
new `features/challenges/`: the existing challenge/badge widgets already live there and
Wrapped/badges are the same surface, so a split would fragment one concept.
- `data/models/challenge_model.dart` — `ChallengeModel`, `ChallengeEntryModel`, `BadgeModel`,
  `UserBadgeModel` + `ChallengeStatus`/`EntryVerificationLevel` enums. `EntryVerificationLevel`
  is **deliberately separate** from `ExpenseVerificationLevel` (values differ:
  `evidence_backed`, not `verified`).
- `data/repositories/challenge_repository.dart` — full CRUD, multipart entry recording,
  badge catalog + mine.
- `providers/challenge_providers.dart` — `challengesProvider` (AsyncNotifier),
  `challengeEntriesProvider`, `badgeCatalogProvider`, `myBadgesProvider`. Recording an entry
  invalidates badges too, since an entry can earn one.
- Added the user-scoped ones to `session_reset.dart`. `badgeCatalogProvider` is deliberately
  **excluded** — the catalog is a public, non-user-scoped endpoint.

⚠️ **No Challenges UI, and the existing mock UI contradicts the backend.**
`challenge_modal.dart` / `challenge_success_modal.dart` offer three types (`fridaySavings`,
`categoryBudget`, `noSpend`/`weekendChallenge`); the API ships exactly one, `friday_savings`.
Those modals are static, unwired, and reachable only via the routed
`GamificationPreviewScreen`. Two of the three types have nothing behind them, so the mock
can't be wired up as-is — needs a product call before building screens.

Whole-project `flutter analyze` clean. **None of this has been run on a device.**

### 2026-08-03 (2nd sync) — Three silent API breakages fixed; Wrapped is now monthly

Re-diffed the live spec after the backend dev shipped another batch. **Zero path changes** —
everything was in schemas/query params, the kind that breaks at runtime with no compile error.
Three live breakages found and fixed:

1. **`PATCH /expenses/{id}` became multipart** (same `dto` + optional `receipt` shape as
   `POST /expenses`). The client was sending plain JSON → 422 on every expense edit.
   `ExpenseRepository.updateExpense` now sends `FormData` and takes `File? receipt`;
   `ExpenseListNotifier.edit` threads it through. **This also closes the oldest open thread
   in this file** — attaching proof to an *existing* expense is now possible, so
   `evidence_suggested` finally has an action behind it.
   - `ApiClient.uploadFile` gained a `method` param (defaults `POST`) and now uses
     `_dio.request` — needed because this is a multipart **PATCH**. It also logs its response
     now, which it silently wasn't doing before.
2. **Wrapped is a MONTHLY recap, not a year-in-review.** `GET /wrapped` takes `year` **and
   `month`**; `WrappedDto`/`WrappedCoverDto`/`SharePassportDto` gained required `month`,
   `MonthlySavingsDto` gained `year`. Updated the models, `WrappedRepository.getWrapped`,
   and the provider — `wrappedProvider`'s family key changed from `int?` to a
   `WrappedPeriod` record (`({int? year, int? month})`). `WrappedScreen` takes `month` too.
   Fixed two bits of now-wrong copy: slide 4's "biggest category this **year**" → "this
   month", and slide 1's fallback headline now names the month.
3. **`GET /groups/{id}/messages` pages with `page_size`, not `limit`.** The client was sending
   `limit: 50`, which the backend now ignores — chat silently capped at the 20 default.
   Fixed in `GroupRepository.getMessages` (param renamed `limit` → `pageSize`).

Also noted, no client change needed: `POST /auth/logout` now takes an optional
`{device_token}` to unregister push on logout (wire up with the device-token work);
`CategoryDto` gained `user_id`/`icon`/`is_default` (client `CategoryModel` maps `icon` only —
fine until a "delete custom category" flow exists); `cumulative_at_time` and
`MessageResponseDto.sender_id`/`sender_username`/`content` became nullable, which the client
models already handled defensively.

Whole-project `flutter analyze` clean. **Nothing here has been run on a device** — the
Wrapped monthly change in particular deserves a real test, since it changes what the whole
feature means.

### 2026-08-03 — API re-sync: Savings Challenges + device-token push + expense receipt upload

Diffed the live OpenAPI spec (`https://api.finclarai.com/openapi.json`) against
`docs/API.md` again.

**Fixed a live-breaking bug** (same pattern as the 2026-08-02 redistribution fix): `POST
/expenses` (manual create) changed from a plain JSON body to `multipart/form-data` — the
DTO now rides as a JSON-encoded `dto` form field, with an optional `receipt` image alongside
it (attaching one AI-verifies the amount and returns the expense already `verified`). The old
JSON-body call would have started failing once this shipped. Fixed:
- `ExpenseRepository.createExpense` (`lib/features/expenses/data/repositories/expense_repository.dart`)
  now builds `FormData` (`dto` + optional `receipt` `MultipartFile`) and calls
  `ApiClient.uploadFile` instead of `post`. Added an optional `File? receipt` param.
- `ExpenseListNotifier.create` (`expense_providers.dart`) passes `receipt` through; analytics
  method tag becomes `'manual_with_receipt'` when a receipt is attached.
- **Not done:** the manual add-expense sheet (`edit_expense_sheet.dart`) has no UI yet to
  pick/attach a receipt image — the repo/provider plumbing exists but nothing calls it with
  a non-null `receipt`. This only closes the gap for **new** expenses; attaching proof to an
  **existing** expense is still impossible (see `docs/API.md` "Known gap").

**Documentation + `ApiEndpoints` constants only for the rest — no repositories,
providers, or UI built yet.** Next session should treat these as new checklist items, one
slice at a time, same as the 2026-08-02 batch.

- **New: Savings Challenges** (`/challenges/*`) — a weekly savings-streak feature (only
  `friday_savings` type today). Full CRUD + entries (multipart, optional receipt) + a badge
  catalog + "my badges". Entries carry their own `EntryVerificationLevel`
  (`self_reported`/`evidence_backed`) — **deliberately separate** from
  `ExpenseVerificationLevel`, don't reuse that enum/model. Two `dev/*` sub-routes
  (`send-test-reminder`, `simulate-streak`) exist for the backend team only — never wire
  these into the app.
- **New: push device-token registration is live** — `/notifications/device-tokens` (list/
  register/unregister) + `/notifications/test-push`. This closes the gap that's been
  blocking `NotificationService._registerToken` (a stub since 2026-06-15, see the
  2026-06-15 entry below) — implementing it is now unblocked.
- Confirmed **`POST /groups/{group_id}/members` is still not live** (still absent from the
  spec) and no breaking changes to any previously-documented schema (`UserResponseDto`,
  `ExpenseResponseDto`, `WrappedDto`, etc. all unchanged).
- Added `ApiEndpoints.challenges`/`challenge()`/`challengeEntries()`/
  `challengeBadgeCatalog`/`challengeBadgesMine` and `ApiEndpoints.deviceTokens`/
  `deviceToken()`/`testPush`, mirroring the new `docs/API.md` sections.

**Not done yet (flagging so next session doesn't re-derive from scratch):**
- No `ChallengeModel`/`BadgeModel`/`DeviceTokenModel`, no repositories, no providers, no
  screens for Savings Challenges — this is a brand-new feature area, not on
  `CLAUDE.md`'s feature list yet. Needs a product decision on where it lives (own feature
  folder vs. folded into `gamification`) before building.
- `NotificationService._registerToken` still just logs — the endpoint existing doesn't
  mean it's wired up. This is now a straightforward client task (was backend-blocked,
  isn't anymore).

### 2026-08-02 — API re-sync: verification levels, remove-member fix (part 1 of 4)

Diffed the live OpenAPI spec against `docs/API.md` after the backend dev shipped a batch of
changes. **This entry covers the first slice only** — the rest is queued (see below).

**What the spec diff turned up** (all now documented in `docs/API.md`):
- **Expense verification levels are live** — the WhatsApp product suggestion shipped.
  `verification_level` (`verified` | `self_reported`) + `evidence_suggested` on every
  `ExpenseResponseDto`; aggregate `verified_pct`/`self_reported_pct` on the home insight.
- ⚠️ **BREAKING: `GET /insights/home` returns an object** (`HomeInsightDto`), not a string.
  Not actually broken in the app — `ExpenseRepository.getHomeInsight` already read
  `data['insight']` defensively — but we discard 7 new fields (`available_balance`,
  `verified_pct`, …).
- ⚠️ **BREAKING: `DELETE /groups/{id}/members/{id}` requires `?redistribution=self|split`.**
  Our call sent nothing → 422. **Fixed in this session.**
- **New:** `GET /wrapped?year=` (full year-in-review payload, backend-written `headline`
  per section), `PATCH /user/me`.
- `UserResponseDto` gained `preferred_name`, `profile_icon`, `display_name` (read-only,
  resolves preferred→username). Answers the tester complaint about Clara using usernames.
- `clara_insight` now inline on `ExpenseResponseDto` **and** `BudgetResponseDto`.
- `POST /groups/{id}/members` is **still not live** — `GroupRepository.addMember` still 404s.

**Done in this session:**
- `docs/API.md` rewritten against the live spec; `api_endpoints.dart` synced (`wrapped`
  added, `groupMembers` annotated as not-live, `me` noted as GET+PATCH).
- **Remove-member fixed.** New `RedistributionChoice` enum; `removeMember` takes it and
  passes `?redistribution=`. `ApiClient.delete` gained `queryParams` (it had none).
  The provider now **refetches** instead of dropping the row locally — redistribution
  rewrites the *remaining* members' targets server-side, so local trimming left them stale.
  New `remove_member_sheet.dart` asks "split between everyone else" (default) vs "I'll cover
  it", shows the outstanding amount, and skips the question when the member owes nothing.
  Replaced `delete_friend_sheet.dart` (deleted — it was only ever used for this).
- **Verification levels surfaced (display-only).** `ExpenseVerificationLevel` enum +
  `verificationLevel`/`evidenceSuggested`/`claraInsight` on `ExpenseModel`. New
  `expense_verification_badge.dart` — `ExpenseVerificationBadge` (icon+label pill on a
  tinted background, used as a "Source" row on the expense detail card) and
  `ExpenseVerificationLabel` (compact icon+text, no fill, rendered as
  `Category · ✓ Verified` on both the expenses-list tile and home's recent-expenses tile).
- **Two UI corrections after review** (first pass was a 6px colored dot + tooltip):
  - A dot conveyed meaning by **colour alone** (WCAG `color-not-only`) and hid the
    explanation behind a long-press tooltip nobody would discover. Replaced with an
    icon **and** a text label; deliberately non-interactive so it reads at a glance.
  - **The tint colours failed WCAG AA as text.** `AppColors.success` on `successLight`
    is only 3.0:1 and `warning` on `warningLight` 4.4:1. Added `AppColors.successOn`
    (#166534, 6.5:1) / `warningOn` (#854D0E, 6.6:1) plus `context.successOn`/`warningOn`
    extensions, which flip to the pale `*Light` constants in dark mode (13–15:1). Use
    these anywhere text sits on `successBg`/`warningBg` — the base hues are fill/icon
    colours, not text colours.
- **Overflow hardening on long text** (pre-existing bugs, found while fitting the label in):
  - Expense name / merchant now `maxLines: 1` + ellipsis in both tiles — it used to **wrap
    to a second line**, making row heights uneven. Amount is never truncated (the name
    column is the `Expanded` one, so it yields first — money must always stay readable).
  - Category text is `Flexible` + ellipsis so it shrinks before pushing the label out.
  - `ExpenseDetailCard._DetailRow` used `Spacer()` (an `Expanded`) which ate all free space
    and left the value **completely unconstrained** — a long name or note would have thrown
    a render overflow. Now a fixed gap + `Expanded` + right-aligned, `maxLines: 2` ellipsis.

**⚠️ Deliberately NOT built — `evidence_suggested` has no action behind it.** The obvious
move is a "want to attach a receipt?" prompt, but **no endpoint accepts a file for an
existing expense**: `POST /expenses/receipt` *creates a new* expense from an image, and
`PATCH /expenses/{id}` takes no file. Building the prompt would give the user a button that
either does nothing or silently duplicates the expense. Requested from the backend dev —
until it lands, both fields stay display-only.

**Queued next:** nothing — the 2026-08-02 API re-sync checklist is fully worked through
(parts 1–3). Remaining items are all blocked on the backend (see Open threads).

### 2026-08-02 — Preferred name + Wrapped wired to live API (part 3 of 4, final slice)

- **Preferred name.** `UserModel` gained `preferredName`, `profileIcon`, `displayName`.
  `displayName` is backend-computed but the model **also derives it locally** when the field
  is missing (preferred → username), so a stale cached user can never render an empty name.
  New `AuthRepository.updateProfile` (`PATCH /user/me`) + `UserProfileNotifier.updateProfile`,
  which folds the response straight into state and the cache — no refetch, the PATCH returns
  the full user.
  - **Onboarding**: `PreferenceScreen` is now two phases in one screen (`_askingName`) rather
    than a new gated route — the auth-state gate stays a single `_needsGoalsPrompt` flag, so
    the login flow was left untouched. Phase 1 is the new `PreferredNameStep`
    (skippable — backend falls back to `username`, so it costs nothing and keeps signup
    friction low). A failed save keeps the user on the step instead of advancing.
  - **Settings**: `edit_username_sheet.dart` **never saved anything** — it returned a value
    and the screen just called `setState`. Replaced with `edit_preferred_name_sheet.dart`,
    which persists via `updateProfile`. Old file deleted.
  - Home greeting + settings header now read `displayName`. Left `username` in
    `bank_selection_screen` (Mono customer payload — an integration field, not UI).
- **Wrapped.** `WrappedModel` + 9 section models (`features/gamification/data/models/`),
  `WrappedRepository`, `wrappedProvider` (family on nullable year). Added to `session_reset`.
  - `WrappedScreen` is now a `ConsumerWidget` that fetches and handles loading/error+retry;
    the story itself moved to `WrappedStory`, which **only ever renders with real data** —
    no half-populated slides.
  - **The slide list is dynamic.** `top_category` is null for a year with no expenses, so
    that slide is skipped. That made two hardcoded indices wrong, both fixed:
    `WrappedProgressBar` hardcoded **8 pills** (now `totalSteps`), and the footer button
    switched on literal pages `0`/`7` (now first / `_totalSlides - 2`).
  - All 9 slides were **fully hardcoded mock data** and now take typed section models.
    Backend `headline` strings render verbatim per the API contract.
  - **Removed two fabricated claims** that had no backing field: the savings slide's
    "24% faster compared to March" badge, and slide 7's second paragraph + "Recommendation"
    card (`WrappedTip` only carries `title` + `body`). Better a smaller slide than an
    invented number in a shareable artifact.
  - Category bars are sized relative to the **largest** category (0.35–1.0), not to 100%,
    so the chart still reads when one category dominates. Colors cycle a fixed palette —
    the backend sends no per-category color.
  - Percentages that divide by income are guarded against a zero-income year.
  - **Overflow: slides are fixed-height and must NEVER scroll** (explicit user call). A long
    backend headline caused a 40px RenderFlex overflow on slide 5. Fixed by **bounding the
    variable-length content**, not by making it scrollable:
    - New **`WrappedAutoText`** — measures with `TextPainter` and binary-searches the
      largest font size (to within 0.5pt) that fits the given `maxLines` at the available
      width. Respects `MediaQuery.textScalerOf` so system text scaling still works.
      **Long copy shrinks rather than truncating**; ellipsis only applies if it still
      doesn't fit at the minimum. No package added (`auto_size_text` not needed).
    - `WrappedHeadline` 48→28pt over 2 lines; `WrappedSubtitle` and slide 2's backend
      subtitle 20→14pt over 3. **Every** backend-driven `Text` in the slides now uses it
      (4, 6, 7, 8, 9) — there is no `TextOverflow.ellipsis` left in any slide file, only
      the fallback inside `WrappedAutoText`.
    - ⚠️ `WrappedAutoText` needs a **bounded width** to measure (it no-ops on infinite
      width). The passport's two `Row`s had unbounded `Column`s, so their names are now
      wrapped in `Expanded`. Anything new put inside a `Row` needs the same.
    - Per-slide `Text`s that don't use those shared widgets (slide 2 subtitle, 4, 6, 7, 8, 9)
      got explicit `maxLines` + ellipsis.
    - Slide 3 now **sorts categories by amount and takes the top 5** — the list was
      unbounded and the backend can return more than the design fits.
    - A scroll-when-overflowing helper was tried first and **removed** — do not reintroduce
      scrolling here. (The `SingleChildScrollView` inside slide 9's passport card is
      pre-existing and uses `NeverScrollableScrollPhysics` — it clips, it doesn't scroll.)
  - **Passport slot mapping corrected.** The passport has two name-ish slots and they were
    mis-wired on the first pass: `_UserRow` (beside the photo) is designed as *name over
    handle*, and got `personalityName` by mistake, while the actual personality row further
    down stayed hardcoded as "The pragmatic planner". Now: `_UserRow` = profile
    `displayName` (falling back to `username`) over `data.username`, and the personality row
    = `data.personalityName`. `displayName` is threaded from `WrappedScreen` →
    `WrappedStory` → the slide, since `SharePassportDto` carries only a username.
  - **Unused on the passport:** `year`, `top_category`, `badge_name` — no slot in the Figma
    design. Top category and the badge do appear on slides 4 and 8, so nothing is lost in
    the story; they'd only matter if the shared passport image should restate them.
  - **Hold-to-pause** on the story (`onLongPressStart`/`End`/`Cancel` around the `PageView`).
    Resumes from where it paused rather than restarting the slide. Horizontal swipe still
    wins the gesture arena, so paging between slides is unaffected.
  - **Settings → "Money passport" had `onTap: () {}`** — the row was never wired, so the
    only way into Wrapped was Settings → Gamify → the preview screen. Now pushes
    `RouteNames.wrapped`. (Settings → "Rate Finclar AI" is still an empty `onTap` — needs a
    store-review link, not done here.)

### 2026-08-02 — Rich home insight + inline Clara notes (part 2 of 4)

Second slice of the same API re-sync. Consumes the fields the 2026-08-02 backend changes
added but that we were discarding.

- **`HomeInsightModel`** (`features/home/data/models/`) replaces the bare `String` from
  `ExpenseRepository.getHomeInsight()`; `homeInsightProvider` is now
  `FutureProvider<HomeInsightModel>`. The repository still **tolerates a bare string**
  response so a backend rollback can't blank the home card.
- **Verification transparency on the home Clara card.** New private `_VerificationSplit` —
  a 4px green/amber proportion bar plus "Based on X% verified · Y% self-reported", with a
  `Semantics` label. Hidden entirely when both percentages are 0 (a period with no
  expenses), where the split would be meaningless. This is what makes the per-expense
  badges from part 1 add up to something.
  - `selfReportedPctRounded` is derived as `100 - verifiedPctRounded` rather than rounded
    independently, otherwise the pair can read as 99% or 101%.
  - ⚠️ `_GradientBorderCard` paints a **fixed light background in both themes**, so the
    split deliberately uses `AppColors.successOn`/`warningOn` directly, **not** the
    theme-aware `context.*On` getters — the dark-mode variants are pale and would vanish
    on that light card. Same trap applies to anything else added to this card.
- **Balance card now uses backend `available_balance`** instead of
  `ExpenseSummaryModel.balance` (`monthlyIncome - totalExpense`), so client and server
  can't drift. It reads `homeInsightProvider` now; verified every existing invalidation
  site refreshes both providers together, so no staleness regression. (Adding an expense
  invalidates *neither* — pre-existing, unchanged, still needs pull-to-refresh.)
- **New shared `ClaraNote`** (`shared/widgets/clara_note.dart`) — renders an inline
  `clara_insight`; returns `SizedBox.shrink()` on null/blank so callers pass the raw field
  without guarding. Shown on the expense detail screen.
- **Budget screen's Clara card was showing fake AI text** — a locally composed
  "You've used X% of your ₦Y budget." It now prefers `BudgetModel.claraInsight` from the
  backend and keeps the composed sentence only as a fallback. `BudgetModel` gained
  `claraInsight`. (`GET /budgets/{id}/insight` was never wired and is now unnecessary for
  the common case.)
- **Not done:** the balance card's loading state is still a `CupertinoActivityIndicator`
  rather than a skeleton (CLAUDE.md §8). `AppSkeleton` has no color overrides and renders
  grey-on-orange there; giving it themeable colors is a separate change.

Also outstanding for the backend dev: Clara losing conversation context, and Clara not
saying plainly that figures typed into the chat aren't saved to the account.

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
