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

> Pure UI — no backend endpoints exist or are planned yet.

| Item | Impl | Tested |
|---|---|---|
| Badges screen + badge widget | [x] | [ ] |
| Wrapped (9 slides) | [x] | [ ] |
| Challenges (modal, amount sheet, success modal) | [x] | [ ] |
| Streak card modal | [x] | [ ] |
| Real data feeding gamification | [ ] (blocked) | [ ] |

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
