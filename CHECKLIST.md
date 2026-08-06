# Finclar AI — Implementation & Testing Checklist

> Status legend: **Impl** = code exists and is wired. **Tested** = manually verified end-to-end on a device/simulator (happy path + error states).
> Nothing has been tested yet — every Tested box starts unchecked.
> Update this file whenever a feature is built, wired, or verified.

---

## 1. Core Infrastructure

| Item | Impl | Tested |
|---|---|---|
| `ApiClient` (Dio wrapper, `ApiResponse<T>` envelope) | [x] | [ ] |
| `ApiEndpoints` in sync with `docs/API.md` (base URL `api.finclarai.com`) | [x] | [ ] |
| Auth interceptor — Bearer header injection | [x] | [ ] |
| Auth interceptor — 401 → refresh → retry queue | [x] | [ ] |
| Refresh failure → force logout | [x] | [ ] |
| Logging interceptor + `Log` wrapper | [x] | [ ] |
| `StorageService` (secure token storage) | [x] | [ ] |
| `AuthStateService` — session persistence + router redirect (`/startup` gate) | [x] | [ ] |
| `AppConfigNotifier` — currency persistence + `currencySymbolProvider` | [x] | [ ] |
| `applyCurrency()` called after login/verify/reset | [x] | [ ] |
| Theme provider (light/dark/system, persisted to prefs) | [x] | [ ] |
| Dark mode UI toggle in Settings (Appearance sheet → light/dark/system) | [x] | [ ] |
| `PaginatedResponse<T>` parser (needed for `GET /expenses`) | [x] | [ ] |
| `BiometricService` (`local_auth` in pubspec, no service) | [x] | [ ] |
| `NotificationService` (FCM packages in pubspec, no service) | [x] | [ ] |

---

## 2. Splash & Onboarding

| Item | Impl | Tested |
|---|---|---|
| 3-page splash carousel → sign up / login | [x] | [ ] |
| Startup redirect: returning user skips splash | [x] | [ ] |
| Terms of Service screen | [x] | [ ] |
| Privacy Policy screen | [x] | [ ] |

---

## 3. Auth

### Endpoints

| Endpoint | Impl | Tested |
|---|---|---|
| `POST /auth/register` | [x] | [ ] |
| `POST /auth/verify-email` | [x] | [ ] |
| `POST /auth/resend-otp` | [x] | [ ] |
| `POST /auth/login` | [x] | [ ] |
| `POST /auth/refresh` (via interceptor) | [x] | [ ] |
| `POST /auth/logout` | [x] | [ ] |
| `POST /auth/logout-all` | [x] | [ ] |
| `POST /auth/forgot-passcode` | [x] | [ ] |
| `POST /auth/reset-passcode` | [x] | [ ] |
| `POST /auth/onboarding/goals` — submits selected goal UUIDs | [x] | [ ] |
| `POST /auth/social` (Firebase token sign-in) | [ ] | [ ] |
| `GET /goals` (fetch selectable goals) | [x] | [ ] |
| `GET /user/check-username` | [x] | [ ] |
| `GET /user/me` (`userProfileProvider`) | [x] | [ ] |

### Flows

| Flow | Impl | Tested |
|---|---|---|
| Sign up → OTP email → verify → passcode → preference → home | [x] | [ ] |
| Username availability check during sign up | [x] | [ ] |
| Login with email + passcode | [x] | [ ] |
| Forgot passcode → OTP → reset → auto-login | [x] | [ ] |
| Resend OTP (with loading overlay) | [x] | [ ] |
| Preference (goals) screen — fetches `GET /goals`, submits selected UUID | [x] | [ ] |
| Skip goals | [x] | [ ] |
| Session persists across app restart | [x] | [ ] |
| Access token expiry mid-session → silent refresh | [x] | [ ] |
| Biometric login (Face ID / fingerprint) — returning-user passcode replay | [x] | [ ] |
| Verify phone screen (route exists — backend support unknown) | [ ] | [ ] |

---

## 4. Income (Home)

| Item | Impl | Tested |
|---|---|---|
| `GET /income/sources` | [x] | [ ] |
| `POST /income/sources` (custom source via add-source sheet) | [x] | [ ] |
| `GET /income` | [x] | [ ] |
| `POST /income` (first-time setup) | [x] | [ ] |
| `PATCH /income` (edit via details sheet) | [x] | [ ] |
| Income setup screen (amount, source, recurrence, date, note) | [x] | [ ] |
| Income details / edit sheet | [x] | [ ] |
| Home balance card shows real income | [x] | [ ] |
| Home header shows username from `/user/me` | [x] | [ ] |
| Currency symbol from `default_currency` everywhere | [x] | [ ] |
| AI setup flow (route `/app/home/ai-setup`) | [ ] | [ ] |
| Home: recent expenses section fed by real API data | [x] | [ ] |
| Home: spending card / chart fed by `GET /expenses/summary` | [ ] | [ ] |
| Home: budget section fed by `GET /budgets` (backend now live) | [ ] | [ ] |
| Spending screen fed by `GET /expenses/summary` | [ ] | [ ] |

---

## 5. Expenses

> Backend is fully live and **now wired**: `ExpenseRepository` + `expenseListProvider` (pagination, month filter, CRUD) + `categoriesProvider`. List, summary, detail, add/edit/delete, category picker, and home recent-expenses all run on real data with skeleton loaders.

### Endpoints

| Endpoint | Impl | Tested |
|---|---|---|
| `GET /expenses` (paginated + filters) | [x] | [ ] |
| `POST /expenses` (manual) | [x] | [ ] |
| `GET /expenses/{id}` | [x] (repo method; UI uses list extra) | [ ] |
| `PATCH /expenses/{id}` | [x] | [ ] |
| `DELETE /expenses/{id}` | [x] | [ ] |
| `POST /expenses/receipt` (multipart OCR upload) | [x] (repo method; scanned-screen not yet calling) | [ ] |
| `GET /categories` (10 backend categories with UUIDs) | [x] | [ ] |
| `GET /expenses/summary` (month totals, category breakdown, trends) | [ ] | [ ] |

### UI / Flows

| Flow | Impl | Tested |
|---|---|---|
| Expenses list screen (summary card, category bar, list) | [x] | [ ] |
| Expense list wired to API (pagination, pull-to-refresh) | [x] | [ ] |
| Expense detail / preview screen | [x] | [ ] |
| Add manual expense (edit sheet, category, date sheets) | [x] | [ ] |
| Add expense wired to `POST /expenses` | [x] | [ ] |
| Edit expense wired to `PATCH` | [x] | [ ] |
| Delete expense (sheet) wired to `DELETE` | [x] | [ ] |
| Category sheets use backend category UUIDs (`categoriesProvider`) | [x] | [ ] |
| Month filter wired to `start_date`/`end_date` query params | [x] | [ ] |
| AI receipt scan (OpenAI vision via `ReceiptAiService`; replaced ML Kit) | [x] | [ ] |
| Scanned expense screen (edit/delete items) | [x] | [ ] |
| Scanned receipt → saved to backend (`POST /expenses` or `/expenses/receipt`) | [ ] | [ ] |
| Skeleton loaders on expense list fetch | [x] | [ ] |

---

## 6. Bank Integration (Mono)

> Backend live. UI screens exist; no repository, no Mono Connect SDK integration.

| Item | Impl | Tested |
|---|---|---|
| `GET /banks/available` (bank picker list) | [ ] | [ ] |
| `POST /banks/link` (Mono Connect code exchange) | [ ] | [ ] |
| `GET /banks` (linked accounts) | [ ] | [ ] |
| `POST /banks/{id}/sync` | [ ] | [ ] |
| `DELETE /banks/{id}` (disconnect) | [ ] | [ ] |
| Bank selection screen (currently static list) | [x] | [ ] |
| Bank linking sheet / modal | [x] | [ ] |
| Bank linking success screen | [x] | [ ] |
| Mono Connect widget/SDK flow on mobile | [ ] | [ ] |
| My Accounts screen (settings) wired to `GET /banks` | [ ] | [ ] |
| Synced bank transactions appear in expenses (`source: bank_sync`) | [ ] | [ ] |

---

## 7. Budget

> **Backend now LIVE** (was blocked). Full CRUD + per-category allocations exist. UI built; **not yet wired** — no repository/providers.

| Item | Impl | Tested |
|---|---|---|
| Budget list screen + summary card + chart | [x] | [ ] |
| Create budget screen + allocation/category sheets | [x] | [ ] |
| Budget details / delete sheets | [x] | [ ] |
| `GET /budgets` (list) | [ ] | [ ] |
| `POST /budgets` (create) | [ ] | [ ] |
| `GET /budgets/{id}` (detail) | [ ] | [ ] |
| `PATCH /budgets/{id}` (edit) | [ ] | [ ] |
| `DELETE /budgets/{id}` | [ ] | [ ] |
| `PUT /budgets/{id}/allocations` (upsert category allocation) | [ ] | [ ] |
| `DELETE /budgets/{id}/allocations/{category_id}` | [ ] | [ ] |
| Allocation category picker uses `categoriesProvider` UUIDs | [ ] | [ ] |

---

## 8. Groups

> **Backend LIVE + fully wired** (2026-07-06). Full CRUD + membership + savings entries
> + chat (messages/attachments) plus a separate Friends system (search/invite/accept/
> decline/remove). Repositories (`FriendRepository`, `GroupRepository`), models, and
> providers (`friendsProvider`, `friendInvitesProvider`, `userSearchProvider`,
> `groupsProvider`, `groupDetailProvider`, `groupSavingsProvider`, `groupMessagesProvider`)
> are all live; every group screen runs on real data with skeleton loaders. Remaining gaps
> are UI surfaces only: no dedicated friend-invites inbox, no edit-group / delete-group UI.

| Item | Impl | Tested |
|---|---|---|
| Group list, create, detail screens | [x] | [ ] |
| Group chat screen (bubbles, input bar, media preview) | [x] | [ ] |
| Friends: add / edit / delete sheets, limits sheets | [x] | [ ] |
| Share group / leave group sheets | [x] | [ ] |
| `GET /friends/search` (user search sheet, debounced) | [x] | [ ] |
| `GET /friends` (accepted friends → group member picker) | [x] | [ ] |
| `POST /friends/invite` (add-friend sheet) | [x] | [ ] |
| `GET /friends/invites`, accept/decline | [x] (providers/repo; no dedicated invites screen yet) | [ ] |
| `DELETE /friends/{id}` (remove friend) | [x] (provider; not surfaced in a screen) | [ ] |
| `GET/POST /groups` (list + create) | [x] | [ ] |
| `GET /groups/{id}` (detail w/ members) | [x] | [ ] |
| `PUT /groups/{id}` (edit) | [x] (repo/provider; no edit-group UI yet) | [ ] |
| `DELETE /groups/{id}` | [x] (provider; not surfaced in a screen) | [ ] |
| `POST /groups/{id}/leave` | [x] | [ ] |
| `GET /groups/{id}/share` (invite link) | [x] | [ ] |
| `PUT/DELETE /groups/{id}/members/{member_id}` | [x] | [ ] |
| `POST/GET /groups/{id}/savings` (record-savings sheet) | [x] | [ ] |
| `GET/POST /groups/{id}/messages`, `POST /groups/{id}/messages/attachment` | [x] | [ ] |
| `WS /groups/{id}/ws` realtime chat (via `GroupChatHubService`, one socket per group, app-session-scoped) | [x] | [x] (verified 101 handshake + live `connected`/`message` frames) |
| In-app group chat notification banner (tap → opens that group's chat) | [x] | [ ] (not yet device-tested — needs a message while app is on another screen) |
| Group API wiring (repository + providers) | [x] | [ ] |
| Skeleton loaders on group list / detail / chat / friends fetch | [x] | [ ] |

---

## 9. Settings

| Item | Impl | Tested |
|---|---|---|
| Settings main screen (profile header, rows) | [x] | [ ] |
| Change passcode (forgot → OTP → reset reuse) | [x] | [ ] |
| Logout sheet (loading + error handling) | [x] | [ ] |
| Contact us / message screen | [x] | [ ] |
| FAQ screen | [x] | [ ] |
| Account deletion screen — UI only, **no backend endpoint** | [x] | [ ] |
| My accounts screen — UI only (wire to `GET /banks`) | [x] | [ ] |
| Edit username sheet — UI only, **no backend endpoint** | [x] | [ ] |
| Appearance row → theme selection sheet (`themeProvider`) | [x] | [ ] |
| Biometric login toggle (auth-gated, persisted) | [x] | [ ] |
| Logout-all ("log out of all devices") exposed in UI | [ ] | [ ] |

---

## 9b. Settings — Social Auth (new endpoint)

| Item | Impl | Tested |
|---|---|---|
| `POST /auth/social` (Firebase token → token pair) | [ ] | [ ] |
| Google / Apple sign-in buttons wired to social auth | [ ] | [ ] |
| Firebase Auth set up on client (needed for social) | [ ] | [ ] |

---

## 10. Subscription

> **Blocked: no backend endpoints yet.**

| Item | Impl | Tested |
|---|---|---|
| Plans screen, plan cards, feature rows | [x] | [ ] |
| Active subscription / cancellation sheets | [x] | [ ] |
| Subscription API wiring + payments | [ ] (blocked) | [ ] |

---

## 11. Gamification

> No longer UI-only. `/challenges/*`, `/wrapped` and `/expenses/streak` are all live and wired.

| Item | Impl | Tested |
|---|---|---|
| Badges screen + badge widget | [x] | [ ] |
| Wrapped (9 slides) | [x] | [ ] |
| Challenges (modal, amount sheet, success modal) | [x] | [ ] |
| Streak card modal | [x] | [ ] |
| Real data feeding gamification | [x] | [x] unit |

---

## 12. Clara AI / Insights

> `GET /insights/home` is **live** — returns an AI-generated insight string for the Clara card. There is **no `/ai/chat`** endpoint (full chat not on backend).

| Item | Impl | Tested |
|---|---|---|
| Clara card on home | [x] | [ ] |
| `GET /insights/home` wired to Clara card | [ ] | [ ] |
| Skeleton on Clara card while insight loads | [ ] | [ ] |
| Full chat screen / history | [ ] (no backend) | [ ] |

---

## 13. Cross-Cutting / Quality

| Item | Impl | Tested |
|---|---|---|
| Dark mode renders correctly on every screen | [ ] | [ ] |
| iOS swipe-back works on all pushed routes | [x] | [ ] |
| API errors → `AppSnackbar.error` everywhere | [x] | [ ] |
| Field validation → inline `errorText` everywhere | [x] | [ ] |
| Loading states follow CLAUDE.md rules (button spinner / overlay / skeleton) | [x] | [ ] |
| Offline / network-failure behavior (graceful errors, no crashes) | [ ] | [ ] |
| `flutter analyze` clean | [ ] | [ ] |
| Push notifications (FCM setup, token registration, categories) | [ ] | [ ] |

---

## Known Issues (fix before testing the affected flows)

1. ~~**Onboarding goals payload**~~ — fixed: `preference_screen.dart` now fetches `GET /goals` (`goalsProvider`) and submits the selected goal's UUID; visuals keyed by backend `key`.
2. ~~**`GET /expenses` envelope**~~ — fixed: `PaginatedResponse<T>` now parses top-level `data: [...]` + sibling `pagination` object; use `ApiClient.getPaginated(...)`.
3. **OCR endpoint path** — constant renamed to `ApiEndpoints.expenseReceipt` (`/expenses/receipt`); old `/expenses/ocr` never shipped.
4. ~~**Category UUIDs**~~ — fixed: expense sheets now use `categoriesProvider` (`GET /categories`) and submit category UUIDs.

---

## 14. API Gap Audit — 2026-08-04

> Source: the live spec at `https://api.finclarai.com/openapi.json` (75 paths), diffed against
> `ApiEndpoints` **and** actual call sites. Ordered biggest-first; work it bottom-to-top.

### 14.1 Challenge types — backend has three, the app only speaks one

`ChallengeType` is live as `friday_savings | no_spend | budget_category`. `ChallengeResponseDto`
carries `target_category_id` and `current_period_spent` to drive the two spend-based types, and
`CreateChallengeDto` accepts `type` + `target_category_id`. The app collapsed all three to Friday
savings. **The UI is correct as designed — this is a data-layer gap only.**

| Item | Impl | Tested |
|---|---|---|
| `ChallengeType` enum carries all three values, round-trips `type` | [x] | [x] unit |
| `target_category_id` + `current_period_spent` parsed on `ChallengeModel` | [x] | [x] unit |
| `ChallengeStatus.failed` parsed — **it was silently landing as `active`**, so a lost challenge read as still running | [x] | [x] unit |
| `createChallenge` sends `type` and `target_category_id` | [x] | [ ] |
| Providers pass `type`/`targetCategoryId` through to the repository | [x] | [ ] |
| Card, detail summary and status labels read correctly per type (spent-vs-saved, cap-vs-goal) | [x] | [ ] |
| Detail screen hides the manual "log savings" CTA on spend-based types — they're scored from logged expenses | [x] | [ ] |
| Start sheet adapts copy/fields per type (weekly target vs spend cap + category picker) | [x] | [ ] |
| Add button gated on an active **`friday_savings`** challenge, not on any active challenge | [x] | [ ] |
| Duplicate `ChallengeType` enum in `challenge_modal.dart` folded into the model's (it spelled it `categoryBudget` vs the backend's `budget_category`) | [x] | [ ] |
| Push `NotificationCategory` maps `no_spend` / `budget_category` to `challenge` | [x] | [ ] |
| **Production entry point for `no_spend` / `budget_category`** — was blocked on a product call | [x] — see §16 | [ ] |

### 14.2 Live endpoints the app never calls

None of these are broken — they're unused backend capability. Each needs a product/design call
before wiring, so they are deliberately **not** built yet.

| Endpoint | What it gives | Impl | Tested |
|---|---|---|---|
| `GET /income/calculate` | income normalised to monthly/annual/weekly/daily | [ ] (needs design) | [ ] |
| `PATCH /income/{id}` | update one income record; app only uses collection-level `PATCH /income` | [ ] (needs design) | [ ] |
| `GET /banks/{id}/balance` | live balance for a linked bank | [ ] (needs design) | [ ] |
| `GET /budgets/{id}/insight` | standalone Clara insight — likely redundant, `BudgetResponseDto` already embeds `clara_insight` | [ ] (probably skip) | [ ] |
| `GET /notifications/device-tokens` + `DELETE /{token_id}` | a "your devices" manager in Settings | [ ] (needs design) | [ ] |
| `POST /notifications/test-push` | fire a test push at yourself | [x] | [ ] |

### 14.3 Stale code and docs

| Item | Impl | Tested |
|---|---|---|
| Delete dead `transactions` / `transaction(id)` constants — `/transactions` exists nowhere in the live spec | [x] | n/a |
| Remove the "⚠️ not live yet, 404s" comment on `groupMembers` — `POST /groups/{id}/members` is live and already called | [x] | n/a |
| `MEMORY.md` said the badges screen was mock — it is wired to `myBadgesProvider` / `badgeCatalogProvider` | [x] | n/a |
| `docs/API.md` said `friday_savings` was the only challenge type; also missing `failed`, `target_category_id`, `current_period_spent` | [x] | n/a |
| `test/challenge_model_test.dart` — 7 unit tests covering type/status parsing and the spend fields | [x] | [x] |
| `flutter analyze` clean after all of the above | [x] | [x] |

### 14.4 Verified clean — no action

- Every response field checked is modelled: `income_expense_trend`, `monthly_income`,
  `verified_pct`, `self_reported_pct`, `amount_paid`/`amount_left`/`amount_assigned`,
  `invite_status`, `share_passport`, `months_on_track`, `compare_at_amount`, `trial_days`,
  `evidence_suggested`, `clara_insight`, `cumulative_at_time`.
- `GET /expenses` uses all ten query params the spec offers; `redistribution` is wired on member removal.
- Multipart shapes match for `POST /expenses`, `/expenses/receipt`, and group savings.
- **Push-after-logout is already handled** — `authRepository.logout()` sends `device_token` in
  `LogoutDto` so the backend deactivates it. The standalone `DELETE /device-tokens/{id}` is only
  needed for a device-manager UI (14.2), not to fix a leak.
- `/email/*` and `/marketing/*` are backend/web surfaces with no mobile need.

> **Note on 14.1's blocked row:** resolved in §16 — the entry point is a type picker on the
> challenges screen.

---

## 15. Daily Streak — 2026-08-05

> Re-diffed the live spec after the backend dev flagged an update: **77 paths, up from 75.** Both
> new ones are the daily expense-logging streak. This closes the gap logged on 2026-08-04, where
> `streak_card_modal.dart` was UI with nothing behind it.

`GET /expenses/streak` → `ExpenseStreakResponseDto`: `current_streak`, `longest_streak`,
`last_logged_date`, `logged_today`, and a `days[]` window of `{ date, day_label, logged, is_today }`.
Distinct from `ChallengeResponseDto.current_streak`, which counts **weeks** of a Friday Savings
challenge — this one counts **days** and exists with no challenge running. **The modal design is
unchanged; only its inputs are.**

| Item | Impl | Tested |
|---|---|---|
| `ExpenseStreakModel` + `ExpenseStreakDayModel` | [x] | [x] unit |
| `ApiEndpoints.expenseStreak` + `expenseStreakSimulate(days)` | [x] | n/a |
| `StreakRepository` (`getStreak`, `simulateStreak`) | [x] | [ ] |
| `expenseStreakProvider`, invalidated on every expense create (manual **and** receipt) | [x] | [ ] |
| Added to `session_reset.dart` — the streak is user-scoped and must not leak across logins | [x] | [ ] |
| Modal reads real counts; day labels come from the backend, never derived client-side | [x] | [ ] |
| Streak indicator row derived from `days[]` — a run of logged days collapses into one pill, each missed day is a hollow circle (was hardcoded 3 sparkles + 4 circles) | [x] | [ ] |
| `Day streak` vs `Days streak` singular fix, and personal-best copy when `current >= longest` | [x] | [ ] |
| Fires once per day on the first expense logged, gated on `AppConstants.streakModalDateKey` | [x] | [ ] |
| Wired at both log points: manual add (`app_shell`) and receipt confirm (`scanned_expense_screen`) | [x] | [ ] |
| Fails silently — a streak fetch error never blocks logging an expense | [x] | [ ] |
| `POST /expenses/streak/dev/simulate?days=` in the dev tools sheet, showing the real modal | [x] | [ ] |
| Preview gallery uses a named fixture, not the shipping path | [x] | n/a |
| `docs/API.md` documents both endpoints and the "day_label is backend-supplied" rule | [x] | n/a |
| `test/expense_streak_model_test.dart` — 5 unit tests | [x] | [x] |

**Assumption made, flag if wrong:** the modal fires on the **first expense logged each day**, at
most once per day. The backend supplies no "should I celebrate" flag, and firing on every log
would be noise. If it should instead be milestone-only (7/30/100 days) or a tap target on the home
screen, that's a one-line change in `maybeShowStreakModal`.

### 15.1 Still open after this sync

- ~~14.1's blocked row~~ resolved in §16.
- Everything in 14.2 is unchanged; no new endpoints for any of it.
- `test/widget_test.dart` fails — the scaffold smoke test boots the app without Firebase. It
  predates all of this work (fails on a clean tree) and is unrelated, but it does mean
  `flutter test` is red by default.

---

## 16. Challenge types — production entry point — 2026-08-05

Closes 14.1's blocked row. `no_spend` and `budget_category` were already supported end-to-end in
the data layer and rendered correctly everywhere; nothing in the shipping UI could *start* one.

**Product call made:** the entry point is a **type picker on the challenges screen** — not a second
scheduled prompt. Reason: a prompt has to pick its moment (the Friday one earns that by being
tied to Friday), while "which challenge do I want" is a deliberate choice the user makes when
they go looking. Both existing start points (the `+` in the top bar and the empty state's
"Start challenge") now open the picker.

| Item | Impl | Tested |
|---|---|---|
| `challenge_type_sheet.dart` — `showChallengeTypeSheet(context, running:)` returns `ChallengeType?` | [x] | [ ] |
| Rows show icon + label + blurb; types with an active challenge read "Already running", are dimmed and not tappable | [x] | [ ] |
| `+` button now hides only when **all three** types are running (was: any active `friday_savings`) | [x] | [ ] |
| `no_spend` / `budget_category` → the finished `showChallengeModal` intro, whose CTA opens the create form | [x] | [ ] |
| `friday_savings` → straight to the create form, skipping its intro | [x] | [ ] |
| `_titleFor` / `_blurbFor` moved out of `start_challenge_sheet.dart` into `challengeTypeLabel()` / `challengeTypeBlurb()` in `challenge_utils.dart` — picker and form share one copy source | [x] | [ ] |
| `AppColors.challengePurpleMuted` added (no muted purple existed for the picker icon wash) | [x] | n/a |
| Picker added to the Gamify gallery for design review | [x] | n/a |

**Why Friday skips its intro:** that modal *is* the weekly save prompt. Its two CTAs ("Start
saving" / "Enter amount") record an entry against an existing challenge — they don't create one.
Reusing it in a creation flow would have meant either two buttons doing the same thing or adding
a flag that changes its designed layout. The other two intros are pure explainers with a single
CTA, so they slot in unchanged.

### 16.1 Bug found and fixed while wiring this

Live `UpdateChallengeDto` is **`name`, `weekly_target`, `overall_target`, `end_date` only** — no
`target_category_id`, contrary to what `docs/API.md` claimed ("same shape as `CreateChallengeDto`").
The edit sheet let you re-pick the capped category and silently dropped it on save. Now the
category row is read-only when editing (no chevron, not tappable) and `docs/API.md` is corrected.

### 16.2 Still open

- ~~The challenges empty state still reads "Beat the Friday test"~~ — rewritten in §17.
- Nothing verifies the backend actually permits three concurrent active challenges. The picker
  assumes one-per-type; if the backend rejects a second concurrent challenge, the error surfaces
  as a snackbar from the create form rather than being pre-empted in the picker.

---

## 17. Challenges — cadence, cards and the modal fix — 2026-08-05

Challenges are meant to *arrive*, not sit behind a `+`. Each type now has a cadence and a card,
and the intro modal no longer disappears the moment it opens something.

### 17.1 The modal bug (reported from device)

Tapping **Start saving** / **Enter amount** popped the modal *before* running the action, so the
amount sheet opened over an empty screen. Dismissing that sheet by mistake lost the flow entirely —
the only way back was Settings → Challenges.

`showChallengeModal` callbacks are now `ChallengeModalAction = Future<bool> Function()`. The modal
stays mounted, spins the CTA that was pressed, and closes **only** when the action returns `true`
(entry recorded / challenge created) or the user taps ✕. `barrierDismissible: false` and
`PopScope(canPop: false)` stop a stray tap or back-swipe killing it mid-flow.

| Item | Impl | Tested |
|---|---|---|
| Modal survives a dismissed amount sheet and can be retried | [x] | [ ] |
| Pressed CTA shows its own spinner; both CTAs disabled while one runs | [x] | [ ] |
| ✕ still closes at any idle moment; disabled while an action is in flight | [x] | [ ] |
| Backdrop tap / system back no longer dismiss | [x] | [ ] |

### 17.2 Cadence per type

`lib/features/gamification/domain/challenge_availability.dart` is the single source of truth,
covered by `test/challenge_availability_test.dart` (11 tests).

| Type | Window | Prompt |
|---|---|---|
| `friday_savings` | always open | every Friday, once per ISO week (unchanged) |
| `no_spend` | **Fri 00:00 → Sun 23:59 local** | once per weekend; created with `end_date` = weekend end so the backend expires it |
| `budget_category` | always open | a **random** date 5–12 days out, rescheduled every time it fires |

| Item | Impl | Tested |
|---|---|---|
| `maybeShowChallengePrompts()` replaces the Friday-only call on home — at most one modal per app open, priority Friday → weekend → category | [x] | [ ] |
| Weekend prompt guarded by `weekend_prompt_week`; skipped when a `no_spend` challenge is already active | [x] | [ ] |
| Category prompt guarded by `category_prompt_date`; a fresh install only schedules, never fires on day one | [x] | [ ] |
| Category prompt reschedules even when skipped, so it can't fire the instant an active one ends | [x] | [ ] |
| Push routing reads `challenge_type`/`type` and sends each to its own prompt (was: everything → Friday) | [x] | [ ] |
| Gamify gallery gained three "force" tiles so weekend/category prompts can be tested off-window | [x] | n/a |

### 17.3 Challenges screen

| Item | Impl | Tested |
|---|---|---|
| Sections: **Ongoing** → **Start a challenge** → **Past challenges** | [x] | [ ] |
| `AvailableChallengeCard` — tinted card per startable type with icon, blurb and a window pill | [x] | [ ] |
| Out-of-window cards stay visible but dimmed and inert, pill reads "Opens Friday" with a lock | [x] | [ ] |
| `PastChallengeGroup` collapses finished runs of one type into a `×N` row, expandable to the individual cards; a single run renders as a plain card | [x] | [ ] |
| Type picker (`+`) also respects windows — closed types dimmed with a lock | [x] | [ ] |
| Empty state copy generalised to "Put your money where your mouth is"; its button dropped in favour of the cards below it | [x] | [ ] |
| `challenge_type_style.dart` — icon/colour per type, shared by picker, cards and groups | [x] | n/a |

### 17.4 Second bug found while wiring this

`maybeShowFridayChallengePrompt` took the **first active challenge of any type**. With three types
live, a running `no_spend` challenge could be picked up by the Friday prompt and have a savings
entry recorded against it. Now scoped to `type == friday_savings`.

### 17.5 Still open

- **No local notification when the weekend opens.** The app can only *receive* push, and a genuine
  "Weekend challenge is available" alert has to be sent by the backend — `firebase_messaging` has
  no local-scheduling API and `flutter_local_notifications` isn't a dependency (adding one needs a
  decision). Client side is ready: a push with `challenge_type: no_spend` routes straight to the
  weekend prompt. Until the backend sends it, the prompt only appears when the app is opened
  during the weekend.
- Weekend boundaries use **device local time**, so travelling across a timezone can shift the
  window by a day. Backend `end_date` is a plain date, so this can't be fully resolved client-side.
- Prompt schedule keys (`weekend_prompt_week`, `category_prompt_date`) aren't cleared on logout —
  same as the pre-existing `challenge_prompt_week` and `streak_modal_date`. Two accounts on one
  device share a prompt schedule.
- ~~Badge aggregation was **already** `×N` per month~~ — the grouping was there, but the `×N` was a
  14px corner chip, not the design's treatment. Redone in §18. The settings "challenges" entry is
  still just a link to this screen.

---

## 18. Badges screen — built from Figma `37:6044` — 2026-08-05

### 18.1 Artwork normalisation

The three shield PNGs were exported from Figma with different trims (and the category badge with a
long soft shadow the others lack), so a square `BoxFit.contain` box landed each shield at a
different height — no stable anchor for the count. Regenerated onto a common 512×512 canvas with the
opaque art at a fixed size and its bottom edge at 86%, written to
`assets/images/gamification/badges/`. Sources in `assets/images/gamification/` are untouched.

| Item | Impl | Tested |
|---|---|---|
| `assets/images/gamification/badges/{friday_savings,budget,no_spend_weekend}.png` — normalised, registered in `pubspec.yaml` | [x] | [ ] |
| Art resolves by badge **category**, not key (`badgeArtPath`) — catalog is 21 badges / 7 categories | [x] | [ ] |
| `no_spend` streak badges reuse the weekend shield; `budget_category` reuses the budget shield | [x] | [ ] |
| `badgeColor('no_spend_weekend')` corrected blue → `AppColors.primary` (matches the art) | [x] | [ ] |
| `streak` / `expense_streak` → `AppColors.streakGold`, no shield yet → tinted icon fallback | [x] | [ ] |

### 18.2 The `×N` count

| Item | Impl | Tested |
|---|---|---|
| Large outlined number on the shield's tail — white fill + badge-colour stroke, Bricolage SemiBold | [x] | [ ] |
| Scales with the tile: font 19%, stroke 25% of font, centre at 85% of height | [x] | [ ] |
| Shows on **every** earned badge including `1x` (the mock shows `1X`) | [x] | [ ] |
| Locked badges: greyscale + 0.6 opacity, no count | [x] | [ ] |
| Same treatment in the badge detail sheet (size 180) and success modal (no count passed) | [x] | [ ] |

### 18.3 Screen layout

| Item | Impl | Tested |
|---|---|---|
| 3-per-row grid (was a horizontal scroller), tile = width / 3, square | [x] | [ ] |
| Month header `"<Month> badges"` — Geist Medium 16 / `textQuaternary` (`#4D4845`), 8px above the grid | [x] | [ ] |
| No name label under badges that have a shield — the ribbon names them | [x] | [ ] |
| Fallback badges keep a 2-line 10px caption so streak badges stay identifiable | [x] | [ ] |
| Skeleton mirrors the grid (3 circles per row, no caption bones) | [x] | [ ] |

### 18.4 Still open

- `assets/images/gamification/` ships several unused/duplicate downloads that will end up in the
  bundle: `Badge 3.pngbadge_friday_savings_goal_reached.png` (byte-identical to
  `friday_savings_goal_reached.png` — a save accident, and the reason the Friday shield never
  rendered), `badge_budget_hero.png` (actually the budget *mascot*), and the
  `badge_no_spend_weekend.png` / `no_spend_weekend.png` and
  `badge_category_budget_hero.png` / `category_budget_hero.png` pairs. Left in place — deleting
  source art is the user's call.
- 18 of the 21 catalog badges (all the streak families) still have no shield and render as tinted
  icons. Needs artwork, not code.
- The mock lists future months (May/June/July) as locked goal rows; the screen still groups by the
  month a badge was *earned* plus the current month. Changing that is a product decision, not a
  design one.
