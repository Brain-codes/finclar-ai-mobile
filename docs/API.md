# Finclar AI — Backend API Reference

> **Live base URL:** `https://api.finclarai.com/api/v1`
> **Swagger UI:** `https://api.finclarai.com/docs`
> **OpenAPI JSON:** `https://api.finclarai.com/openapi.json`
>
> ⚠️ Base URL changed from `finclar-ai.onrender.com` to `api.finclarai.com` (2026-06-13). Update any cached/hardcoded references.
>
> ✅ **2026-07-06:** Diffed against the live OpenAPI spec — **Friends** (search/invite/accept/decline/remove) and full **Groups** (CRUD, membership, savings entries, chat messages + attachments) are now live, plus public `POST /marketing/newsletter/subscribe` and `POST /marketing/waitlist`. None of these are wired into the app yet — see `MEMORY.md` open threads.
>
> ✅ **2026-08-02:** Diffed against the live spec again. Changes since 2026-07-20:
> - **Expense verification levels** are live — `verification_level` (`verified` | `self_reported`)
>   and `evidence_suggested` on every `ExpenseResponseDto`. ⚠️ **There is no endpoint to attach
>   proof to an existing expense**, so `evidence_suggested` currently has no action behind it.
> - ⚠️ **BREAKING — `GET /insights/home` now returns an object** (`HomeInsightDto`), not a bare
>   string, and accepts optional `start_date`/`end_date`.
> - ⚠️ **BREAKING — `DELETE /groups/{id}/members/{member_id}` now requires `?redistribution=`.**
> - **New:** `GET /wrapped` (year-in-review), `PATCH /user/me`.
> - `UserResponseDto` gained `preferred_name`, `profile_icon`, `display_name`.
> - `clara_insight` added to `ExpenseResponseDto` and `BudgetResponseDto`.
> - `POST /groups/{group_id}/members` is **still not live** (client still 404s on it).
>
> ✅ **2026-08-11:** Diffed against the live spec again (81 paths, was 77). Changes since 2026-08-03:
> - **New:** In-app notification feed — `GET /notifications`, `GET /notifications/unread-count`,
>   `PUT /notifications/read-all`, `PUT /notifications/{id}/read`. Wired into the app; the
>   notifications screen no longer serves mock data.
> - ⚠️ `NotificationType` is a **fixed server enum** (`budget_near_limit`, `friend_invite`,
>   `group_invite`, `group_activity`, `bank_sync_completed`, `subscription_activated`) and does
>   **not** match the app's old ad-hoc `transaction`/`budget`/`group`/`insight`/`system` set.
>   The client maps unrecognised values to `unknown` rather than throwing.
> - ✅ **`POST /groups/{group_id}/members` is finally live** (was "planned" since 2026-07).
>   ⚠️ The body is `AddMemberDto` = `{ "user_id": "<uuid>" }` — **not** the `recipient_id` we
>   had guessed, so the client was 422-ing rather than 404-ing. Fixed client-side
>   (`GroupRepository.addMember`).
>
> ✅ **2026-08-03:** Diffed against the live spec again. Changes since 2026-08-02:
> - **New:** Savings Challenges (`/challenges/*`) — weekly savings-streak challenges with
>   entries, badges, and a badge catalog. Not wired into the app yet.
> - **New:** Push notification device-token registration is finally live
>   (`/notifications/device-tokens`, `/notifications/test-push`) — this fills the gap that
>   was blocking `NotificationService._registerToken` (previously a stub, see
>   `MEMORY.md` open threads).
> - ⚠️ **BREAKING — `POST /expenses` (manual expense) is now `multipart/form-data`, not a
>   plain JSON body.** It carries a JSON-encoded `dto` form field plus an optional `receipt`
>   image — attaching one AI-verifies the entered amount and marks the expense `verified`.
>   This is the first bit of "attach evidence" support for **new** expenses (see [Expense
>   verification levels](#expense-verification-levels) — attaching proof to an *existing*
>   expense is still not possible). Fixed client-side same day: `ExpenseRepository.createExpense`
>   now sends multipart and takes an optional `receipt` file.
> - `POST /groups/{group_id}/members` is **still not live** — confirmed absent from the spec
>   again today.
> - No other breaking changes: `UserResponseDto`, `ExpenseResponseDto` (aside from the create
>   request shape above), `WrappedDto`, and all previously-documented schemas are unchanged.
>
> ✅ **2026-08-03 (second sync, later same day):** Re-diffed. **No path changes** — every
> change is in schemas/params, which is exactly the kind that breaks silently:
> - ⚠️ **BREAKING — `PATCH /expenses/{id}` is now `multipart/form-data`** (same `dto` +
>   optional `receipt` shape as `POST /expenses`). The client was sending a plain JSON body →
>   422. **This also closes the long-standing "attach proof to an existing expense" gap** —
>   `evidence_suggested` finally has an action behind it. Fixed client-side.
> - ⚠️ **BREAKING — Wrapped is now MONTHLY, not a year-in-review.** `GET /wrapped` takes
>   `year` **and `month`**; `WrappedDto`, `WrappedCoverDto`, and `SharePassportDto` all gained
>   a required `month`, and `MonthlySavingsDto` gained `year`. Fixed client-side.
> - ⚠️ **BREAKING — `GET /groups/{id}/messages` now pages with `page_size`, not `limit`.**
>   Fixed client-side.
> - **New:** `POST /auth/logout` accepts an optional body `{ "device_token": "..." }` so the
>   push token is unregistered on logout. ✅ Wired — `AuthRepository.logout` sends it.
> - `CategoryDto` gained `user_id`, `icon`, `is_default` (system vs. user-created).
> - Now nullable: `SavingsEntryResponseDto.cumulative_at_time`, and
>   `MessageResponseDto.sender_id` / `sender_username` / `content`. Client models already
>   handled these defensively — no change needed.
>
> ✅ **2026-08-04:** Re-diffed (75 paths). No new paths. One silent schema gap:
> - **`ChallengeType` has always had three values** — `friday_savings`, `no_spend`,
>   `budget_category` — and `ChallengeStatus` four, including `failed`. The client had
>   collapsed both, so non-Friday challenges parsed as Friday and a `failed` challenge read
>   as `active`. Fixed client-side; see [Savings Challenges](#savings-challenges).
> - `/transactions` does not exist and never has — dead constants removed from `ApiEndpoints`.
>
> ✅ **2026-08-05:** Re-diffed (77 paths). Two new, both the **daily expense-logging streak**:
> - **New:** `GET /expenses/streak` → `ExpenseStreakResponseDto`. Wired client-side.
> - **New:** `POST /expenses/streak/dev/simulate?days=` — QA helper.
> - No schema changes elsewhere; `ChallengeType`/`ChallengeStatus` unchanged from 2026-08-04.
>
> This file is the single source of truth for all backend endpoints.
> Update it every time a new endpoint is added or an existing one changes.
> `ApiEndpoints` in `lib/core/api/api_endpoints.dart` must always mirror this file.

---

## Auth Flow

```
POST /auth/register        → sends OTP to email
POST /auth/verify-email    → verifies OTP, returns token pair  ← user is now logged in
POST /auth/login           → returns token pair
POST /auth/refresh         → exchange refresh_token for new token pair
POST /auth/logout          → invalidate current session (Bearer required)
POST /auth/logout-all      → invalidate all sessions (Bearer required)
```

- `access_token` — valid for **15 minutes**. Send as `Authorization: Bearer <token>` on all 🔒 endpoints.
- `refresh_token` — valid for **30 days**. Exchange it at `/auth/refresh` when the access token expires.
- All protected endpoints are marked with 🔒.

---

## Global Response Envelope

Every response from the API is wrapped in this envelope:

```json
{
  "success": true,
  "message": "Optional human-readable message",
  "data": { ... }
}
```

`data` is `null` on error responses. `message` may be `null` on success. Map this with `ApiResponse<T>` in `lib/core/api/api_response.dart`.

### Paginated list endpoints

The following `GET` list endpoints return the **paginated envelope** — `data` is the array plus a sibling `pagination` object (`PaginationMeta`), just like `/expenses`. They **all** accept `page` / `page_size` query params (as of 2026-08-03 chat messages use `page_size` too, not `limit`):

`/expenses`, `/categories`, `/banks`, `/banks/available`, `/income/sources`, `/goals`, `/budgets`, `/friends`, `/friends/search`, `/friends/invites`, `/groups`, `/groups/{group_id}/savings`, `/groups/{group_id}/messages`, `/clara/messages`, `/challenges`, `/challenges/{challenge_id}/entries`.

The client reads `data` (the array) either way, but to avoid page-1 truncation, list repositories walk all pages via `ApiClient.getAllPaginated<T>()`. Chat/expense lists that page in the UI use `getPaginated<T>()` directly.

---

## Endpoints

### Auth

#### `POST /auth/register`
Create a new account. Sends a 6-digit OTP to the provided email.

**Request body**
```json
{
  "email": "user@example.com",
  "username": "chinasa",
  "passcode": "123456",
  "default_currency": "NGN"   // optional, defaults to "USD" on backend
}
```

**Response** `ApiResponse<dict>`

---

#### `POST /auth/verify-email`
Verify email with the OTP received after registration. Returns a token pair — the user is authenticated from this point.

**Request body**
```json
{
  "email": "user@example.com",
  "code": "839201"
}
```

**Response** `ApiResponse<TokenPairResponseDto>`

---

#### `POST /auth/resend-otp`
Resend a new OTP to the email (registration or forgot-passcode flow).

**Request body**
```json
{
  "email": "user@example.com"
}
```

**Response** `ApiResponse<dict>`

---

#### `POST /auth/login`
Authenticate with email + passcode. Returns a token pair.

**Request body**
```json
{
  "email": "user@example.com",
  "passcode": "123456"
}
```

**Response** `ApiResponse<TokenPairResponseDto>`

---

#### `POST /auth/refresh`
Exchange an unexpired `refresh_token` for a fresh token pair.

**Request body**
```json
{
  "refresh_token": "<refresh_token>"
}
```

**Response** `ApiResponse<TokenPairResponseDto>`

---

#### `POST /auth/logout` 🔒
Invalidate the current session's refresh token.

**Request body** (`LogoutDto`) — optional, may be omitted entirely
```json
{ "device_token": "<fcm_token>" }
```
Added 2026-08-03. Pass the device's FCM token to unregister it for push in the same call, so
a logged-out device stops receiving notifications. See
[Push Notifications](#push-notifications-device-tokens).

**Response** `ApiResponse<dict>`

---

#### `POST /auth/logout-all` 🔒
Invalidate all active sessions for the current user (all devices).

**Response** `ApiResponse<dict>`

---

#### `POST /auth/forgot-passcode`
Trigger a passcode reset. Sends an OTP to the email.

**Request body**
```json
{
  "email": "user@example.com"
}
```

**Response** `ApiResponse<dict>`

---

#### `POST /auth/reset-passcode`
Reset the passcode using the OTP received from forgot-passcode.

**Request body**
```json
{
  "email": "user@example.com",
  "code": "839201",
  "new_passcode": "654321"
}
```

**Response** `ApiResponse<TokenPairResponseDto>` — user is logged in immediately after reset.

---

#### `POST /auth/onboarding/goals` 🔒
Save the user's selected financial goals during onboarding. **Goals are UUIDs** from `GET /goals`, not string keys.

**Request body**
```json
{
  "goals": ["d99a17f5-8c0b-4ea3-94d9-cc8d5532b375", "c2e49ef2-02bd-4217-b889-8fb787cfb143"]
}
```

**Response** `ApiResponse<dict>`

---

#### `POST /auth/social`
Sign in / sign up with a social provider via a Firebase ID token (Google, Apple, etc.). Returns a token pair.

**Request body**
```json
{
  "firebase_token": "<firebase_id_token>",
  "default_currency": "NGN"   // optional, defaults to "NGN"
}
```

**Response** `ApiResponse<TokenPairResponseDto>`

---

### User

#### `GET /user/check-username?username=`
Check whether a username is available before registration. No auth required.

**Query parameter**
| Param | Type | Required | Rules |
|---|---|---|---|
| `username` | string | ✅ | min 1 char, max 50 chars |

**Response** `ApiResponse<dict>`

---

#### `GET /user/me` 🔒
Fetch the authenticated user's profile.

**Response** `ApiResponse<UserResponseDto>`

---

#### `PATCH /user/me` 🔒
Update the authenticated user's profile. All fields optional — send only what changed.

**Request body** (`UpdateUserDto`)
```json
{
  "username": "chinasa",
  "preferred_name": "Chi",
  "is_active": true,
  "default_currency": "NGN",
  "profile_icon": "avatar_3"
}
```

`preferred_name` is what the user wants to be called (Clara should address them by it
rather than by `username`). `display_name` on the response is computed by the backend —
`preferred_name` when set, otherwise `username`. Prefer `display_name` in the UI.

**Response** `ApiResponse<UserResponseDto>`

---

### Income

#### `GET /income/sources` 🔒
List all available income sources (defaults + user's custom ones).

**Response** `ApiResponse<IncomeSourceDto[]>`

---

#### `POST /income/sources` 🔒
Create a custom income source (e.g. "Side hustle").

**Request body**
```json
{
  "name": "Freelance Design"
}
```

**Response** `ApiResponse<IncomeSourceDto>`

---

#### `GET /income` 🔒
Get the authenticated user's current income record.

**Response** `ApiResponse<IncomeResponseDto>`

---

#### `POST /income` 🔒
Create the user's income record (first-time income setup).

**Request body**
```json
{
  "amount": 500000,
  "source_id": "uuid",
  "reoccurrence": "monthly",
  "start_date": "2026-01-01",
  "note": "Main salary"        // optional
}
```

**Response** `ApiResponse<IncomeResponseDto>`

---

#### `PATCH /income` 🔒
Update an existing income record. All fields are optional — send only what changed.

**Request body**
```json
{
  "amount": 600000,
  "reoccurrence": "monthly",
  "source_id": "uuid",
  "start_date": "2026-06-01",
  "note": "Updated salary"
}
```

**Response** `ApiResponse<IncomeResponseDto>`

---

#### `PATCH /income/{income_id}` 🔒
Update **only** the amount of a specific income record by id.

**Request body**
```json
{
  "amount": 600000
}
```
`amount` may be a number or a numeric string.

**Response** `ApiResponse<IncomeResponseDto>`

---

#### `GET /income/calculate` 🔒
Return the user's income normalised across periods (derived from their current income record + reoccurrence). No query params.

**Response** `ApiResponse<IncomeCalculationDto>`
```json
{ "monthly": 500000.0, "annual": 6000000.0, "weekly": 115384.6, "daily": 16438.4 }
```
All values are **numbers**.

---

### Goals

#### `GET /goals` 🔒
List the selectable financial goals (for onboarding).

**Response** `ApiResponse<FinancialGoalDto[]>`

Live data (4 goals): keys are `smart_money_saving`, `track_my_spending`, `stick_to_a_budget`, `feel_more_in_control`; `icon_name` values are `wallet`, `bar-chart`, `pie-chart`, `briefcase`.

---

### Categories

#### `GET /categories` 🔒
List all expense categories.

**Response** `ApiResponse<CategoryDto[]>`

Live data (10 system defaults): Education, Entertainment, Food, Health, Investment, Other, Rent, Shopping, Transportation, Utilities — each with `id` (uuid), `name`, `description`, `icon` (nullable string).

---

#### `POST /categories` 🔒
Create a custom category.

**Request body**
```json
{
  "name": "Gym",
  "description": "Fitness and gym memberships",  // optional
  "icon": "health_line::#E63946"                  // optional — "iconKey" or "iconKey::#RRGGBB"
}
```

`icon` is a single opaque string column with no enum/format enforced by the
client beyond what it sends. The app now packs an icon key from
`categoryPickerIcons` together with a user-picked color as
`iconKey::#RRGGBB` (mirrors the `profile_icon` encoding used for avatars) so
each custom category gets a distinct color instead of colliding with others.
Older rows that only ever stored a bare icon key (or nothing) still decode
fine — see `decodeCategoryIcon` in `expense_category_utils.dart`. ⚠️ Not
verified against backend validation — if `icon` is whitelisted server-side to
exactly the `categoryPickerIcons` keys, the `::#RRGGBB` suffix will be
rejected on create; confirm with backend before relying on this.

**Response** `ApiResponse<CategoryDto>`

---

### Expenses

#### `GET /expenses` 🔒
Paginated, filterable expense list. Returns the `PaginatedResponse` envelope (see [Paginated list endpoints](#paginated-list-endpoints) above).

**Query parameters** (all optional)
| Param | Type | Default | Notes |
|---|---|---|---|
| `page` | int | 1 | |
| `page_size` | int | 20 | |
| `search` | string | — | matches description |
| `category_id` | uuid | — | |
| `source` | enum | — | `manual` \| `receipt` \| `bank_sync` |
| `status` | enum | — | `pending` \| `completed` \| `failed` \| `cancelled` |
| `start_date` | datetime | — | ISO 8601 |
| `end_date` | datetime | — | ISO 8601 |
| `order_by` | enum | `expense_date` | `expense_date` \| `amount` \| `created_at` |
| `order_dir` | enum | `desc` | `asc` \| `desc` |

**Response** `ExpenseListResponseDto` (extends `PaginatedResponse<ExpenseResponseDto[]>`)

> ✅ **New (2026-08-12):** `total_expenses` and `category_breakdown` are computed
> over **every expense matching the current filters**, not just the current
> page — use these instead of summing `data` client-side, which only ever
> totals the loaded page(s). `category_breakdown` reuses the same shape as
> `categories` in `GET /expenses/summary`.

```json
{
  "success": true,
  "message": null,
  "data": [ ...ExpenseResponseDto ],
  "pagination": {
    "page": 1, "page_size": 20, "total": 0,
    "total_pages": 0, "has_next": false, "has_prev": false
  },
  "total_expenses": 65500.0,
  "category_breakdown": [
    { "name": "Education", "amount": 36000.0, "transaction_count": 1, "pct_of_total": 54.96 }
  ]
}
```

---

#### `POST /expenses` 🔒
Create a manual expense.

> ⚠️ **Changed (2026-08-03):** this is now `multipart/form-data`, not a plain JSON body —
> so a receipt image can optionally ride along in the same request.

**Form fields**
| Field | Type | Required | Notes |
|---|---|---|---|
| `dto` | string | ✅ | JSON-encoded `CreateManualExpenseDto` (see below) sent as a form field |
| `receipt` | file (binary) | — | Optional receipt image. If provided, the entered amount is AI-verified against it and the expense comes back `verification_level: "verified"`. |

`dto` JSON shape (`CreateManualExpenseDto`):
```json
{
  "amount": 2500,
  "description": "Lunch",              // optional
  "category_ids": ["uuid"],            // optional, defaults []
  "expense_date": "2026-06-13T10:00:00Z",
  "currency": "NGN",                   // optional
  "items": [                           // optional, defaults []
    { "name": "Jollof rice", "quantity": 2, "unit_price": 1250, "category_id": null }
  ]
}
```

**Response** `ApiResponse<ExpenseResponseDto>` — message: `"Expense recorded."`

---

#### `GET /expenses/{expense_id}` 🔒
Fetch a single expense.

**Response** `ApiResponse<ExpenseResponseDto>`

---

#### `PATCH /expenses/{expense_id}` 🔒
Update an expense. All fields optional — send only what changed.

> ⚠️ **Changed (2026-08-03):** now `multipart/form-data`, not a plain JSON body — same shape
> as `POST /expenses`. **This is the attach-proof-to-an-existing-expense endpoint** that was
> previously missing.

**Form fields**
| Field | Type | Required | Notes |
|---|---|---|---|
| `dto` | string | ✅ | JSON-encoded `UpdateExpenseDto` (below) sent as a form field |
| `receipt` | file (binary) | — | Optional receipt image. AI-verified against `dto.amount` — or the expense's **current** amount when `amount` isn't being changed — and flips the expense to `verification_level: "verified"`. |

`dto` JSON shape (`UpdateExpenseDto`):
```json
{
  "amount": 3000,
  "description": "Updated",
  "category_ids": ["uuid"],
  "expense_date": "2026-06-13T10:00:00Z",
  "currency": "NGN",
  "status": "completed",
  "items": [
    {
      "id": "uuid",                  // REQUIRED — identifies the existing item
      "name": "Jollof rice",         // optional
      "quantity": 2,                 // optional
      "unit_price": 1250,            // optional
      "category_id": "uuid"          // optional
    }
  ]
}
```

`items` (`UpdateExpenseItemDto[]`) edits **existing** line items in place. Only `id` is
required; omitted fields are left untouched. This is the only way to change an item's
category — there is no per-item endpoint. Used for both individual item edits and for
cascading the parent category onto every item ("apply category to all items").

`status` is an enum: `pending` | `completed` | `failed` | `cancelled`.

**Response** `ApiResponse<ExpenseResponseDto>` — includes the updated `items`.

---

#### `DELETE /expenses/{expense_id}` 🔒
Delete an expense.

**Response** `ApiResponse<dict>` — `data: { "message": "Expense deleted." }`

---

#### `POST /expenses/receipt` 🔒
OCR receipt scan. Upload a receipt image; backend extracts the expense.

**Request:** `multipart/form-data` with a single required `image` file field.

**Response** `ApiResponse<ExpenseResponseDto>` — `source` will be `"receipt"`, `file`/`receipt_url` populated, and `verification_level` will be `"verified"`.

> ⚠️ This endpoint **creates a new expense** from the image. It cannot attach a receipt to
> an expense that already exists — see [Expense verification levels](#expense-verification-levels).

---

#### `GET /expenses/summary` 🔒
Aggregated spending summary for a given month — powers the spending screen / charts.

**Query parameters** (both optional; defaults to current month)
| Param | Type | Notes |
|---|---|---|
| `year` | int | e.g. 2026 |
| `month` | int | 1–12 |

**Response** `ApiResponse<ExpenseSummaryDto>`
```json
{
  "month_label": "June 2026",
  "total_expense": 65500.0,
  "mom_change_pct": null,            // % change vs previous month, nullable
  "mom_direction": null,             // "up" | "down" | null
  "monthly_income": 500000.0,
  "categories": [
    { "name": "Education", "amount": 36000.0, "transaction_count": 1, "pct_of_total": 54.96 }
  ],
  "monthly_trend": [
    { "month": "Mar", "year": 2026, "total": 0.0 }
  ],
  "income_expense_trend": [
    { "month": "Jun", "year": 2026, "income": 500000.0, "expense": 65500.0 }
  ]
}
```

---

#### `GET /expenses/streak` 🔒

> ✅ **New — live as of 2026-08-05.** The daily expense-logging streak.

Counts **consecutive days on which the user logged at least one expense**. Entirely
separate from `ChallengeResponseDto.current_streak`, which counts *weeks* of a Friday
Savings challenge — this one exists whether or not any challenge is running.

No parameters.

**Response** `ApiResponse<ExpenseStreakResponseDto>`
```json
{
  "current_streak": 5,
  "longest_streak": 12,
  "last_logged_date": "2026-08-05",   // date, nullable — null before the first log
  "logged_today": true,
  "days": [
    { "date": "2026-08-01", "day_label": "Sa", "logged": true,  "is_today": false },
    { "date": "2026-08-05", "day_label": "We", "logged": true,  "is_today": true  },
    { "date": "2026-08-06", "day_label": "Th", "logged": false, "is_today": false }
  ]
}
```

`day_label` is supplied by the backend and rendered verbatim — the client must not derive
day names itself, or the two will disagree about where the week starts.

#### `POST /expenses/streak/dev/simulate` 🔒 — QA only

Jumps the streak to `days` and fires the same badge/push logic a real log would.

**Query parameters**
| Param | Type | Required | Notes |
|---|---|---|---|
| `days` | int | ✅ | 1–100 |

Returns the same `ExpenseStreakResponseDto`. Only called from the dev-flagged tools sheet.

---

### Expense verification levels

> **New — live as of 2026-08-02.** Every expense is labelled by how trustworthy its figures
> are, so Clara's analysis can be transparent about what it's based on.

Two read-only fields on every `ExpenseResponseDto`:

| Field | Type | Meaning |
|---|---|---|
| `verification_level` | `verified` \| `self_reported` | `verified` = backed by a receipt scan or bank sync. `self_reported` = the user typed it in. |
| `evidence_suggested` | bool | Backend-computed. *"True for large self-reported expenses — a nudge to attach proof, not a requirement."* The amount threshold lives on the backend; the client must not reimplement it. |

Aggregate percentages for a period come from `GET /insights/home`
(`verified_pct` / `self_reported_pct`).

> ✅ **Gap closed (2026-08-03, second sync) — `evidence_suggested` now has an action behind
> it.** Both write paths take an optional `receipt` image:
> - `POST /expenses` — create a new expense already verified.
> - `PATCH /expenses/{id}` — **attach proof to an existing expense**, which is what
>   `evidence_suggested` was always pointing at. The backend AI-verifies the image against the
>   expense's amount and flips `verification_level` to `verified`.
>
> So an "attach a receipt?" prompt on a flagged expense is now buildable end-to-end. The
> repository layer supports both (`ExpenseRepository.createExpense` / `.updateExpense` take an
> optional `File? receipt`); **the UI for it does not exist yet** — see `MEMORY.md`.

---

### Insights

#### `GET /insights/home` 🔒
Money summary + AI insight for the home screen (the Clara card).

> ⚠️ **Changed (2026-08-02):** this used to return a bare string. It now returns a
> `HomeInsightDto` object — the sentence moved to the `insight` field, with the figures it
> was derived from alongside it.

**Query parameters** (both optional; defaults to the current period)
| Param | Type | Notes |
|---|---|---|
| `start_date` | date | ISO `YYYY-MM-DD` |
| `end_date` | date | ISO `YYYY-MM-DD` |

**Response** `ApiResponse<HomeInsightDto>`
```json
{
  "insight": "Hey admin2002! This June, you've spent a total of ₦65,500...",
  "start_date": "2026-06-01",
  "end_date": "2026-06-30",
  "total_income": 500000.0,
  "total_expenses": 65500.0,
  "available_balance": 434500.0,
  "verified_pct": 82.0,
  "self_reported_pct": 18.0
}
```

`verified_pct` / `self_reported_pct` are the share of the period's expenses backed by
evidence vs manually entered — surface these so the user knows what the analysis is based
on. All values are **numbers**. The two percentages are 0–100, not 0–1.

---

### Clara AI Chat

> **New — live as of 2026-07-09.** A conversational assistant (OpenAI tool-calling over the
> user's expense data), **REST request/response — not a socket** (unlike group chat). It only
> discusses the user's own finances. Both the user message and the reply are persisted
> server-side, so the client only appends the reply locally after sending.

#### `POST /clara/chat` 🔒
Send a message; get Clara's reply. When the question is about spending/income for a period,
the reply carries a structured `data` payload (an `ExpenseSummaryDto`) the client renders as
a chart/insight card.

**Request body**
```json
{ "message": "How did I do in April?" }   // 1–2000 chars
```

**Response** `ApiResponse<ClaraChatResponseDto>`
```json
{
  "success": true,
  "message": null,
  "data": {
    "reply": "You spent ₦65,500 in April, about 13% of your income — nicely under control!",
    "data": { ...ExpenseSummaryDto }   // nullable; present when Clara pulled a summary
  }
}
```

#### `GET /clara/messages` 🔒
Paginated chat history (oldest → newest). `PaginationMeta` sibling as usual; client walks all
pages via `getAllPaginated`.

**Response** `PaginatedResponse<ClaraMessageDto>`
```json
{
  "success": true, "message": null,
  "data": [
    { "role": "user", "content": "How did I do in April?", "data": null, "created_at": "..." },
    { "role": "assistant", "content": "You spent ₦65,500...", "data": { ...ExpenseSummaryDto }, "created_at": "..." }
  ],
  "pagination": { ...PaginationMeta }
}
```

**`ClaraMessageDto`**: `{ role: "user"|"assistant", content: string, data: ExpenseSummaryDto|null, created_at: datetime }`. There is **no message `id`**. On the client each backend message expands into a text bubble plus, for assistant messages with `data`, an insight card (see `ClaraMessageModel.listFromBackend`). The `data` here is the same shape as `GET /expenses/summary` (see `ExpenseSummaryDto`).

---

### Banks (Mono)

#### `GET /banks` 🔒
List the user's linked bank accounts.

**Response** `ApiResponse<BankResponseDto[]>`

---

#### `GET /banks/available` 🔒
List all banks available for linking (Nigerian institutions).

**Response** `ApiResponse<dict[]>` — each item: `{ "id": "uuid", "name": "Access Bank", "code": "044", "logo_url": null }`

---

#### `POST /banks/link` 🔒
Link a bank account. Send the `code` returned after the user completes Mono Connect on mobile.

**Request body**
```json
{
  "code": "<mono_connect_code>"
}
```

**Response** `ApiResponse<BankResponseDto>`

---

#### `POST /banks/{bank_id}/sync` 🔒
Pull transactions from the linked bank into expenses.

**Response** `ApiResponse<dict>`

---

#### `GET /banks/{bank_id}/balance` 🔒
Fetch the current balance of a linked bank account.

**Response** `ApiResponse<dict>`

---

#### `DELETE /banks/{bank_id}` 🔒
Disconnect a linked bank.

**Response** `ApiResponse<dict>`

---

### Budgets

> Now **live**. A budget has a total `amount_allocated` and a set of per-category allocations. `spent`, `remaining`, and `pct_used` are computed by the backend.
>
> ⚠️ **Changed (2026-06-22):** create/update now take **only** `amount_allocated` — the
> backend sets `name` (none — there is no `name` field anymore), `start_date`, and
> `end_date` itself (current month). `amount_allocated` accepts a **number or a string**.
> `DELETE /budgets/{id}` now returns `ApiResponse<dict>`, not the budget.

#### `GET /budgets` 🔒
List all of the user's budgets.

**Response** `ApiResponse<BudgetResponseDto[]>`

---

#### `POST /budgets` 🔒
Create a budget. The backend assigns `start_date`/`end_date` (current month) — the
client sends only the amount.

**Request body**
```json
{
  "amount_allocated": 500000
}
```
`amount_allocated` is required and may be a number or a numeric string.

**Response** `ApiResponse<BudgetResponseDto>`

---

#### `GET /budgets/{budget_id}` 🔒
Fetch a single budget with its allocations.

**Response** `ApiResponse<BudgetResponseDto>`

---

#### `PATCH /budgets/{budget_id}` 🔒
Update a budget. Only `amount_allocated` is accepted (optional — the only mutable field).

**Request body**
```json
{
  "amount_allocated": 600000
}
```

**Response** `ApiResponse<BudgetResponseDto>`

---

#### `DELETE /budgets/{budget_id}` 🔒
Delete a budget.

**Response** `ApiResponse<dict>`

---

#### `PUT /budgets/{budget_id}/allocations` 🔒
Create or update a per-category allocation within a budget (upsert by `category_id`).

**Request body**
```json
{
  "category_id": "uuid",
  "amount_allocated": 50000
}
```

**Response** `ApiResponse<BudgetResponseDto>` — returns the full updated budget.

---

#### `DELETE /budgets/{budget_id}/allocations/{category_id}` 🔒
Remove a category allocation from a budget.

**Response** `ApiResponse<BudgetResponseDto>`

---

#### `GET /budgets/{budget_id}/insight` 🔒
AI-generated natural-language insight for a specific budget (per-budget analogue of `GET /insights/home`).

**Response** `ApiResponse<string>` — a plain AI-generated sentence/paragraph.

---

### Friends

> **New — live as of 2026-07-06.** Friend search, invite/accept/decline, and removal.

#### `GET /friends/search?q=` 🔒
Search users by username/email (for adding friends). `q` is required, 1–50 chars.

**Response** `ApiResponse<UserSearchResultDto[]>`

---

#### `GET /friends` 🔒
List accepted friendships for the current user.

**Response** `ApiResponse<FriendshipResponseDto[]>`

---

#### `POST /friends/invite` 🔒
Send a friend invite.

**Request body**
```json
{ "recipient_id": "uuid" }
```

**Response** `ApiResponse<FriendshipResponseDto>` (status `pending`)

---

#### `GET /friends/invites` 🔒
List pending invites (sent and/or received).

**Response** `ApiResponse<FriendshipResponseDto[]>`

---

#### `PUT /friends/invites/{invite_id}/accept` 🔒
Accept a pending invite.

**Response** `ApiResponse<FriendshipResponseDto>` (status `accepted`)

---

#### `PUT /friends/invites/{invite_id}/decline` 🔒
Decline a pending invite.

**Response** `ApiResponse<FriendshipResponseDto>` (status `declined`)

---

#### `DELETE /friends/{friendship_id}` 🔒
Remove an existing friendship.

**Response** `ApiResponse<dict>`

---

### Groups (Group Savings)

> **New — live as of 2026-07-06.** Full CRUD + membership, savings entries, and chat/messages.
> Money fields (`target_amount`, `total_raised`, `balance`, allocation-style amounts) are
> **strings** in responses; `target_amount` on create/update accepts a number or string.

#### `GET /groups` 🔒
List the current user's groups.

**Response** `ApiResponse<GroupResponseDto[]>`

---

#### `POST /groups` 🔒
Create a group savings goal. `member_ids` optionally invites members immediately.

**Request body**
```json
{
  "name": "Lagos Trip",
  "target_amount": 500000,
  "end_date": "2026-12-31",
  "member_ids": ["uuid"]
}
```

**Response** `ApiResponse<GroupDetailResponseDto>`

---

#### `GET /groups/{group_id}` 🔒
Fetch a single group with its members.

**Response** `ApiResponse<GroupDetailResponseDto>`

---

#### `PUT /groups/{group_id}` 🔒
Update a group. All fields optional.

**Request body**
```json
{ "name": "Lagos Trip 2027", "target_amount": 600000, "end_date": "2027-01-31" }
```

**Response** `ApiResponse<GroupResponseDto>`

---

#### `DELETE /groups/{group_id}` 🔒
Delete a group.

**Response** `ApiResponse<dict>`

---

#### `POST /groups/{group_id}/leave` 🔒
Leave a group (current user).

**Response** `ApiResponse<dict>`

---

#### `POST /groups/{group_id}/invite` 🔒
Respond to a pending group invite (the current user accepts or declines being added to the group).

**Request body**
```json
{ "response": "accepted" }
```
`response` is an `InviteResponse` enum: `accepted` | `declined`.

**Response** `ApiResponse<GroupMemberResponseDto?>`

---

#### `GET /groups/{group_id}/share` 🔒
Get a shareable invite link for the group.

**Response** `ApiResponse<dict>` — e.g. `{ "link": "https://..." }`

---

#### `POST /groups/{group_id}/members` 🔒
Add an existing finclar user to an existing group (owner only). The added user lands as `invite_status: pending` and must accept via `POST /groups/{group_id}/invite`. This is how the owner adds friends *after* group creation — at creation, members are set via `member_ids`.

**Request body** (`AddMemberDto`)
```json
{ "user_id": "uuid" }
```

**Response** `ApiResponse<GroupMemberResponseDto>`

---

#### `PUT /groups/{group_id}/members/{member_id}` 🔒
Update a member's target contribution amount.

**Request body**
```json
{ "target_amount": 100000 }
```

**Response** `ApiResponse<GroupMemberResponseDto>`

---

#### `DELETE /groups/{group_id}/members/{member_id}` 🔒
Remove a member from the group.

> ⚠️ **Changed (2026-08-02):** `redistribution` is now a **required** query param. Calls
> without it fail validation (422).

**Query parameter**
| Param | Type | Required | Notes |
|---|---|---|---|
| `redistribution` | `self` \| `split` | ✅ | What happens to the removed member's unmet target: `self` assigns it to you (the owner), `split` divides it equally among the remaining members. |

**Response** `ApiResponse<null>`

---

#### `POST /groups/{group_id}/savings` 🔒
Record a savings contribution to the group. `multipart/form-data`.

**Form fields**
| Field | Type | Required |
|---|---|---|
| `amount` | number or string | ✅ |
| `note` | string | — |
| `receipt` | file (binary) | — |

**Response** `ApiResponse<SavingsEntryResponseDto>`

---

#### `GET /groups/{group_id}/savings` 🔒
List savings entries for the group.

**Response** `ApiResponse<SavingsEntryResponseDto[]>`

---

#### `GET /groups/{group_id}/messages?page=&page_size=` 🔒
Paginated group chat messages. `page` default 1; `page_size` default 20.

> ⚠️ **Changed (2026-08-03):** the size param is now `page_size`, not `limit` — it matches
> every other paginated list endpoint. Passing `limit` silently gets ignored.

**Response** `ApiResponse<MessageResponseDto[]>`

---

#### `POST /groups/{group_id}/messages` 🔒
Send a text message to the group chat.

**Request body**
```json
{ "content": "Hey everyone!" }
```

**Response** `ApiResponse<MessageResponseDto>`

---

#### `POST /groups/{group_id}/messages/attachment` 🔒
Send a file attachment to the group chat. `multipart/form-data`. Optionally records a
savings contribution in the same call.

**Form fields**
| Field | Type | Required |
|---|---|---|
| `file` | file (binary) | ✅ |
| `record_amount` | number or string | — |

**Response** `ApiResponse<MessageResponseDto>`

---

#### `WS /groups/{group_id}/ws?token=<access_token>` 🔒 (WebSocket)
Realtime group chat socket (FastAPI/Starlette). Used for **live text delivery**;
history is still loaded via `GET /groups/{id}/messages`.

- **Scheme:** `wss://api.finclarai.com/api/v1/groups/{group_id}/ws?token=<access_token>`
- **Auth:** the access-token JWT is passed as the `token` **query param** (a WS upgrade
  can't send an `Authorization` header). Server closes `4001` (invalid/expired token)
  or `4003` (not a group member) before accepting.
- **On connect** the server sends: `{ "type": "connected", "group_id": "<uuid>" }`
- **Client → server** (send a text message): `{ "content": "Hello" }` — empty content is
  ignored. **Text only** — the socket loop reads only `content`.
- **Server → all members** (including the sender) on every text message:
  ```json
  { "type": "message", "data": { ...MessageResponseDto } }
  ```
- **Errors:** `{ "type": "error", "message": "..." }`

Both REST send endpoints (`POST /messages` and `POST /messages/attachment`) **also
broadcast** the resulting message over the socket (as of backend commit `ba27006`,
2026-07-06), so every member — including the sender — receives it live.

⚠️ **Client notes (see `group_chat_socket_service.dart` / `group_messages_provider.dart`):**
- **Dedupe by message id.** Every path echoes back over the socket: sending text over the
  socket echoes to the sender, and the REST endpoints now broadcast too. The client must
  dedupe on `id` (it does) so a locally-appended message isn't duplicated by its echo.
- **Text** is sent over the **socket** (`{"content": ...}`), not `POST /messages`. Both
  reach other members now, but the socket path is the primary one; REST send is only a
  fallback used when the socket is disconnected.
- **Attachments** upload via REST `POST /messages/attachment` (the socket loop only reads
  `content`). The client appends the REST response locally for instant feedback; the
  backend's broadcast of that same message is deduped by id, and other members receive it
  live.

---

### Subscriptions

> **Live as of 2026-07-20.** Paystack-backed. Two plans (`go_unlimited_monthly`,
> `go_unlimited_yearly`).
>
> ⚠️ **Checkout is client-side with the PUBLIC key.** There is no server-side
> "initialize" endpoint — `GET /subscriptions/plans` returns `paystack_public_key`, the
> client runs Paystack inline checkout with it, and posts the resulting `reference` to
> `POST /subscriptions/checkout/verify` for server-side verification. A Paystack **secret**
> key must never be shipped in the app; any package requiring one (e.g.
> `flutter_paystack_max`) is unusable here.
>
> ⚠️ **All money fields are integers in MINOR units (kobo for NGN).** Confirmed against
> live data (2026-07-20): monthly `amount: 300000` = ₦3,000. The client divides by 100
> for display (`PlanModel.majorAmount`).

#### `GET /subscriptions/plans` 🔒
List the available plans plus the Paystack public key needed for checkout.

**Response** `ApiResponse<PlansResponseDto>`
```json
{
  "paystack_public_key": "pk_test_...",
  "plans": [
    {
      "code": "go_unlimited_yearly",
      "name": "Clara + yearly",
      "amount": 2800000,
      "compare_at_amount": 3600000,
      "currency": "NGN",
      "interval_days": 365,
      "trial_days": 7,
      "features": ["Advanced analytics...", "Deep AI insights..."]
    }
  ]
}
```
`compare_at_amount` is nullable — when present the client renders the savings badge.
`features` drives the feature list on the subscription screen (no longer hardcoded).

---

#### `GET /subscriptions/me` 🔒
The authenticated user's current subscription.

**Response** `ApiResponse<SubscriptionDto>`

---

#### `POST /subscriptions/checkout/verify` 🔒
Verify a completed Paystack transaction and activate the subscription.

**Request body**
```json
{
  "reference": "<paystack_reference>",
  "plan_code": "go_unlimited_yearly"
}
```

**Response** `ApiResponse<SubscriptionDto>`

---

#### `POST /subscriptions/cancel` 🔒
Cancel at period end — access continues until `current_period_end`.

**Response** `ApiResponse<SubscriptionDto>` — `cancel_at_period_end` becomes `true`.

---

#### `POST /subscriptions/resume` 🔒
Undo a pending cancellation.

**Response** `ApiResponse<SubscriptionDto>`

---

### Wrapped (Monthly Recap)

> **New — live as of 2026-08-02.** A Spotify-Wrapped-style recap that powers the
> gamification / insight-slide screens. Every section carries its own backend-written
> `headline` string — **do not compose this copy on the client.**
>
> ⚠️ **Changed (2026-08-03):** this is a **monthly** recap, not a year-in-review. `month` is
> now a required field on `WrappedDto`, `WrappedCoverDto`, and `SharePassportDto`, and the
> endpoint takes a `month` query param. Any client copy saying "this year" is wrong.

#### `GET /wrapped?year=&month=` 🔒
Full recap payload for one month.

**Query parameters** (both optional; default to the current period)
| Param | Type | Notes |
|---|---|---|
| `year` | int | Calendar year. Defaults to the current year. |
| `month` | int | 1–12. Defaults to the current month. |

**Response** `ApiResponse<WrappedDto>`

---

### Savings Challenges

> **New — live as of 2026-08-03.** Weekly savings-streak challenges — record a contribution each
> week, build a streak, earn badges. Separate from the expense/verification model by design — see
> `EntryVerificationLevel` below.
>
> Three types are live: `friday_savings` (save a `weekly_target` each Friday), `no_spend` (spend
> nothing over the period), and `budget_category` (stay under a cap in one category — pass
> `target_category_id`). The spend-based types report progress via `current_period_spent` rather
> than `total_saved`.

#### `POST /challenges` 🔒
Create a challenge.

**Request body** (`CreateChallengeDto`) — all fields optional
```json
{
  "type": "friday_savings",
  "name": "Friday Savings Challenge",
  "weekly_target": 5000,
  "overall_target": 260000,
  "target_category_id": "uuid",
  "end_date": "2026-12-31"
}
```
`weekly_target`/`overall_target` may be a number or numeric string. `type` defaults to
`friday_savings`. `name` defaults to `"Friday Savings Challenge"` server-side if omitted.
`target_category_id` applies to `budget_category` only — it names the category being capped.

**Response** `ApiResponse<ChallengeResponseDto>`

---

#### `GET /challenges` 🔒
Paginated list of the user's challenges.

**Query parameters**
| Param | Type | Default | Notes |
|---|---|---|---|
| `page` | int | 1 | |
| `page_size` | int | 20 | |
| `status` | enum | — | `active` \| `completed` \| `cancelled` |

**Response** `PaginatedResponse<ChallengeResponseDto[]>`

---

#### `GET /challenges/{challenge_id}` 🔒
Fetch a single challenge.

**Response** `ApiResponse<ChallengeResponseDto>`

---

#### `PUT /challenges/{challenge_id}` 🔒
Update a challenge. All fields optional (`UpdateChallengeDto`): `name`, `weekly_target`,
`overall_target`, `end_date`.

⚠️ **No `type` and no `target_category_id`** — unlike `CreateChallengeDto`. A challenge's type
and capped category are fixed at creation, so the edit sheet renders the category read-only.

**Response** `ApiResponse<ChallengeResponseDto>`

---

#### `DELETE /challenges/{challenge_id}` 🔒
Cancel a challenge.

**Response** `ApiResponse<null>`

---

#### `POST /challenges/{challenge_id}/entries` 🔒
Record a weekly entry. `multipart/form-data`.

**Form fields**
| Field | Type | Required |
|---|---|---|
| `amount` | number or string | — |
| `note` | string | — |
| `receipt` | file (binary) | — |

`verification_level` on the response entry is `evidence_backed` when a receipt was attached,
else `self_reported` — mirrors the expense verification concept but is a **separate enum**
(`EntryVerificationLevel`), kept isolated from `ExpenseVerificationLevel` by the backend.

**Response** `ApiResponse<ChallengeEntryResponseDto>`

---

#### `GET /challenges/{challenge_id}/entries` 🔒
Paginated list of entries for a challenge.

**Response** `PaginatedResponse<ChallengeEntryResponseDto[]>`

---

#### `GET /challenges/badges/catalog`
List all badges that exist (no auth required).

**Response** `ApiResponse<BadgeResponseDto[]>`

---

#### `GET /challenges/badges/mine` 🔒
List badges the current user has earned.

**Response** `ApiResponse<UserBadgeResponseDto[]>`

---

> ⚠️ **Dev/debug-only, do not wire into the app:** `POST
> /challenges/{challenge_id}/dev/send-test-reminder` and `POST
> /challenges/{challenge_id}/dev/simulate-streak?weeks=` exist purely for the backend team to
> trigger push/badge logic without waiting a real week. `simulate-streak` mutates real streak
> state. Neither belongs behind any user-facing action.

---

### Marketing

> Public (no auth) — used by the marketing site, not the mobile app, but documented for completeness.

#### `POST /marketing/newsletter/subscribe`
```json
{ "email": "user@example.com", "name": "Chinasa" }
```
**Response** `ApiResponse<dict>`

---

#### `POST /marketing/waitlist`
```json
{ "email": "user@example.com", "name": "Chinasa" }
```
**Response** `ApiResponse<dict>`

---

### Notifications (In-App Feed)

> **New — live as of 2026-08-11.** Backs the notifications screen.

#### `GET /notifications` 🔒
Paginated notification feed, newest first.

**Query params:** `unread_only` (bool, default `false`), `page` (default `1`),
`page_size` (default `20`).

**Response** `PaginatedResponse<NotificationResponseDto>`

---

#### `GET /notifications/unread-count` 🔒
Unread badge count.

**Response** `ApiResponse<{ "count": int }>`

---

#### `PUT /notifications/{notification_id}/read` 🔒
Mark one notification read.

**Response** `ApiResponse<NotificationResponseDto>`

---

#### `PUT /notifications/read-all` 🔒
Mark every unread notification read.

**Response** `ApiResponse<null>`

---

#### `NotificationResponseDto`
```json
{
  "id": "uuid",
  "type": "budget_near_limit",
  "title": "...",
  "body": "...",
  "data": { },
  "is_read": false,
  "read_at": null,
  "created_at": "2026-08-11T09:00:00Z"
}
```
`type` (`NotificationType` enum): `budget_near_limit` | `friend_invite` | `group_invite` |
`group_activity` | `bank_sync_completed` | `subscription_activated`.
`data` is a freeform deep-link payload whose shape varies per `type`.

---

### Push Notifications (Device Tokens)

> **Live as of 2026-08-03.** Fully wired — `NotificationService._registerToken` calls this on
> startup and again after login; `POST /auth/logout` carries the `device_token` to unregister.

#### `GET /notifications/device-tokens` 🔒
List the current user's registered device tokens.

**Response** `ApiResponse<DeviceTokenResponseDto[]>`

---

#### `POST /notifications/device-tokens` 🔒
Register (or re-register) an FCM device token.

**Request body** (`RegisterDeviceTokenDto`)
```json
{ "token": "<fcm_token>", "platform": "ios" }
```
`platform` (`DevicePlatform` enum): `ios` | `android` | `web`.

**Response** `ApiResponse<DeviceTokenResponseDto>`

---

#### `DELETE /notifications/device-tokens/{token_id}` 🔒
Unregister a device token (e.g. on logout).

**Response** `ApiResponse<null>`

---

#### `POST /notifications/test-push` 🔒
Debug only — sends a plain push to the caller's own registered devices, to confirm
registration + FCM are wired up. Not a user-facing action.

**Response** `ApiResponse<null>`

---

#### Custom notification sound

The app bundles a custom tone (`notification_tone`) and has both platforms configured to use it
as the **default** sound whenever a push payload doesn't say otherwise:

- **Android:** `finclar_default_channel` is created client-side bound to
  `res/raw/notification_tone.mp3`, and is set as the default FCM channel via manifest meta-data —
  so any `notification`-type FCM message with no `android.notification.channel_id` in its payload
  automatically plays this tone.
- **iOS:** `notification_tone.caf` ships in the app bundle. APNs does **not** default to it — the
  backend must set `"sound": "notification_tone.caf"` inside `aps` on every push payload sent to
  iOS devices, otherwise iOS falls back to the default system tone.

If a payload needs a different Android channel (e.g. silent), it must explicitly set
`android.notification.channel_id` to something other than `finclar_default_channel`.

---

### Health

#### `GET /health`
Health check. No auth required.

**Response** `{ "status": "ok" }`

---

## Schemas

### `TokenPairResponseDto`
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer"
}
```

### `UserResponseDto`
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "username": "chinasa",
  "preferred_name": "Chi",
  "is_active": true,
  "is_email_verified": true,
  "default_currency": "NGN",
  "profile_icon": "avatar_3",
  "created_at": "2026-01-01T00:00:00Z",
  "display_name": "Chi"
}
```
`preferred_name` and `profile_icon` are nullable. `display_name` is **read-only** and
backend-computed (`preferred_name` if set, else `username`) — use it anywhere the app shows
the user's name.

### `HomeInsightDto`
```json
{
  "insight": "Hey admin2002! This June, you've spent...",
  "start_date": "2026-06-01",
  "end_date": "2026-06-30",
  "total_income": 500000.0,
  "total_expenses": 65500.0,
  "available_balance": 434500.0,
  "verified_pct": 82.0,
  "self_reported_pct": 18.0
}
```
All fields required. Money and percentages are **numbers**; percentages are 0–100.

### `IncomeSourceDto`
```json
{
  "id": "uuid",
  "name": "Salary",
  "is_default": true
}
```

### `IncomeResponseDto`
```json
{
  "id": "uuid",
  "amount": "500000.00",
  "source_id": "uuid",
  "source_name": "Salary",
  "reoccurrence": "monthly",
  "note": null,
  "start_date": "2026-01-01"
}
```

### `IncomeCalculationDto`
```json
{ "monthly": 500000.0, "annual": 6000000.0, "weekly": 115384.6, "daily": 16438.4 }
```
All values are **numbers**.

### `IncomeReoccurrence` (enum)
```
daily | weekly | monthly | one_time
```

### `FinancialGoalDto`
```json
{
  "id": "uuid",
  "key": "smart_money_saving",
  "name": "Save more money",
  "description": "Help me understand my spending...",
  "icon_name": "wallet"
}
```

### `CategoryDto`
```json
{
  "id": "uuid",
  "user_id": null,
  "name": "Food",
  "description": "Groceries, restaurants, and food delivery.",
  "icon": "food",
  "is_default": true
}
```
`user_id`, `description`, and `icon` are nullable. `is_default` is `true` for the 10 system
categories and `false` for user-created ones — `user_id` is set only on the latter (added
2026-08-03). `CategoryModel` on the client does not yet map `user_id`/`is_default`; add them
if a "delete my custom category" flow is ever built.

### `ExpenseResponseDto`
```json
{
  "id": "uuid",
  "amount": "2500",
  "type": "debit",
  "direction": "outbound",
  "status": "completed",
  "currency": null,
  "description": "Lunch",
  "expense_date": "2026-06-13T10:00:00Z",
  "source": "manual",
  "file": null,
  "categories": [ { "id": "uuid", "name": "Food" } ],
  "items": [
    {
      "id": "uuid",
      "name": "Jollof rice",
      "quantity": 2,
      "unit_price": "1250.00",
      "total_price": "2500.00",
      "category_id": null
    }
  ],
  "receipt_url": null,
  "clara_insight": "Lunch spending is up 20% on last month.",
  "verification_level": "self_reported",
  "evidence_suggested": false
}
```
`type`, `direction`, `status`, `currency`, `description`, `source` are all nullable. `source` is `manual | receipt | bank_sync`.

- `clara_insight` — nullable AI one-liner about this specific expense, included inline (no
  extra request needed).
- `verification_level` / `evidence_suggested` — see
  [Expense verification levels](#expense-verification-levels). Both read-only.

### `ExpenseVerificationLevel` (enum)
```
verified | self_reported
```

### `ExpenseStatus` (enum)
```
pending | completed | failed | cancelled
```

### `BankResponseDto`
```json
{
  "id": "uuid",
  "name": "Access Bank",
  "account_number": "0123456789",
  "mono_account_id": "..."
}
```

### `ExpenseSummaryDto`
```json
{
  "month_label": "June 2026",
  "total_expense": 65500.0,
  "mom_change_pct": 12.5,
  "mom_direction": "up",
  "monthly_income": 500000.0,
  "categories": [ "CategoryExpenseSummaryDto" ],
  "monthly_trend": [ "MonthlyTrendPointDto" ],
  "income_expense_trend": [ "IncomeExpenseTrendPointDto" ]
}
```
- `CategoryExpenseSummaryDto`: `{ name, amount, transaction_count, pct_of_total }`
- `MonthlyTrendPointDto`: `{ month, year, total }` (`total` nullable)
- `IncomeExpenseTrendPointDto`: `{ month, year, income, expense }`

All monetary values here are **numbers**, not strings (unlike `ExpenseResponseDto.amount`).

### `BudgetResponseDto`
```json
{
  "id": "uuid",
  "amount_allocated": 500000.0,
  "spent": 65500.0,
  "remaining": 434500.0,
  "pct_used": 13.1,
  "start_date": "2026-06-01",
  "end_date": "2026-06-30",
  "allocations": [ "AllocationResponseDto" ],
  "clara_insight": "You're pacing well — 13% used with most of the month left."
}
```
- There is **no `name`** field on a budget (removed 2026-06-22). `start_date`/`end_date`
  are always present (backend-assigned, current month).
- `clara_insight` (added 2026-08-02) is an AI one-liner delivered inline, defaulting to `""`.
  It makes a separate `GET /budgets/{id}/insight` call unnecessary for the common case.
- `AllocationResponseDto`: `{ id, category_id, category_name, category_icon, amount_allocated, spent, remaining, pct_used }` — `category_icon` is a nullable string.
- Budget money fields are **numbers** in responses; on create/update requests
  `amount_allocated` may be sent as a number or a numeric string.

### `PlanDto`
```json
{
  "code": "go_unlimited_yearly",
  "name": "Clara + yearly",
  "amount": 2800000,
  "compare_at_amount": 3600000,
  "currency": "NGN",
  "interval_days": 365,
  "trial_days": 7,
  "features": ["..."]
}
```
`PlanCode` enum: `go_unlimited_monthly | go_unlimited_yearly`. `amount` and
`compare_at_amount` are **integers in minor units**; `compare_at_amount` is nullable.

### `SubscriptionDto`
```json
{
  "plan_code": "go_unlimited_yearly",
  "status": "active",
  "amount": 2800000,
  "currency": "NGN",
  "trial_end": "2026-07-27T00:00:00Z",
  "current_period_start": "2026-07-20T00:00:00Z",
  "current_period_end": "2027-07-20T00:00:00Z",
  "cancel_at_period_end": false,
  "canceled_at": null
}
```
Only `status` is required — every other field is nullable (a user who has never
subscribed comes back with just a status). The client treats `active` and `trialing`
as subscribed.

### `PaginationMeta`
```json
{
  "page": 1,
  "page_size": 20,
  "total": 0,
  "total_pages": 0,
  "has_next": false,
  "has_prev": false
}
```

### `UserSearchResultDto`
```json
{ "id": "uuid", "username": "chinasa", "email": "user@example.com" }
```

### `FriendshipResponseDto`
```json
{
  "id": "uuid",
  "requester_id": "uuid",
  "recipient_id": "uuid",
  "status": "pending",
  "created_at": "2026-07-06T00:00:00Z",
  "friend_id": "uuid",
  "friend_username": "chinasa",
  "friend_email": "user@example.com"
}
```
`FriendshipStatus` enum: `pending | accepted | declined`.

### `GroupResponseDto`
```json
{
  "id": "uuid",
  "name": "Lagos Trip",
  "target_amount": "500000.00",
  "end_date": "2026-12-31",
  "owner_id": "uuid",
  "created_at": "2026-07-06T00:00:00Z",
  "total_raised": "0.00",
  "balance": "0.00",
  "days_left": 178,
  "member_count": 1,
  "progress_percent": 0.0,
  "shareable_link": "https://...",
  "amount_paid": "0.00",
  "amount_left": "500000.00",
  "amount_assigned": "0.00",
  "invite_status": "accepted"
}
```
`invite_status` (`GroupInviteStatus`: `pending | accepted | declined`) is the **current user's own** invite state for this group — a `pending` group in `GET /groups` is an invitation the user hasn't responded to yet.

### `GroupDetailResponseDto`
Same fields as `GroupResponseDto` plus `members: GroupMemberResponseDto[]`.

### `GroupMemberResponseDto`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "username": "chinasa",
  "status": "pending",
  "invite_status": "pending",
  "target_amount": "100000.00",
  "contributed_amount": "0.00",
  "joined_at": "2026-07-06T00:00:00Z"
}
```
- `GroupMemberStatus` enum (`status`): `pending | complete | left | removed` — tracks **contribution** progress, not invitation.
- `GroupInviteStatus` enum (`invite_status`): `pending | accepted | declined` — tracks whether the member has accepted the group invite. Only `accepted` members appear on the group detail card.

### `SavingsEntryResponseDto`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "amount": "50000.00",
  "cumulative_at_time": "50000.00",
  "note": "First contribution",
  "file_url": null,
  "recorded_at": "2026-07-06T00:00:00Z"
}
```

### `MessageResponseDto`
```json
{
  "id": "uuid",
  "group_id": "uuid",
  "sender_id": "uuid",
  "sender_username": "chinasa",
  "role": "user",
  "message_type": "text",
  "content": "Hey everyone!",
  "file_url": null,
  "extra_data": null,
  "sent_at": "2026-07-06T00:00:00Z"
}
```
`MessageRole` enum: `user | assistant`. `MessageType` enum: `text | image | system`.

### `WrappedDto`
```json
{
  "year": 2026,
  "month": 8,
  "start_date": "2026-08-01",
  "end_date": "2026-08-31",
  "symbol": "₦",
  "cover": { "year": 2026, "month": 8, "username": "chinasa", "headline": "Your August in money" },
  "income_vs_expense": {
    "total_income": 6000000.0, "total_expenses": 4200000.0,
    "net_balance": 1800000.0, "headline": "You kept ₦1.8M of what you earned"
  },
  "spending_breakdown": {
    "total_expenses": 4200000.0,
    "categories": [ "CategoryShareDto" ],
    "headline": "Food led the way"
  },
  "top_category": {
    "name": "Food", "icon": "food", "amount": 1400000.0,
    "percentage": 33.3, "headline": "A third of your spending was Food"
  },
  "savings": {
    "savings_rate": 30.0, "total_saved": 1800000.0,
    "headline": "You saved 30% of your income",
    "monthly_trend": [ "MonthlySavingsDto" ]
  },
  "personality": { "key": "planner", "name": "The Planner", "description": "..." },
  "tip": { "title": "Try the 50/30/20 rule", "body": "..." },
  "badge": {
    "key": "on_track", "name": "On Track", "headline": "...",
    "description": "...", "months_on_track": 9, "months_tracked": 12
  },
  "share_passport": {
    "username": "chinasa", "year": 2026, "month": 8,
    "total_income": 6000000.0, "total_expenses": 4200000.0, "total_saved": 1800000.0,
    "top_category": "Food", "personality_name": "The Planner", "badge_name": "On Track"
  }
}
```
- `year` + `month` identify the period — **this is a monthly recap** (changed 2026-08-03).
- `top_category` is **nullable** (a month with no expenses has none). Every other section is
  always present.
- `CategoryShareDto`: `{ name, icon (nullable), amount, percentage }`
- `MonthlySavingsDto`: `{ year (int), month (1–12, int), income, expenses, net_saved }` —
  gained `year` on 2026-08-03.
- `symbol` is the user's currency symbol — use it rather than re-deriving from
  `default_currency`.
- All money values are **numbers**; percentages are 0–100.
- Every `headline` is written by the backend. Render it as-is.
- `share_passport` is the flattened subset intended for the shareable image/card.

### `ChallengeResponseDto`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "type": "friday_savings",
  "name": "Friday Savings Challenge",
  "weekly_target": "5000.00",
  "overall_target": "260000.00",
  "total_saved": "45000.00",
  "current_streak": 9,
  "longest_streak": 9,
  "last_entry_week": "2026-08-01",
  "target_category_id": null,
  "current_period_spent": null,
  "start_date": "2026-06-01",
  "end_date": "2026-12-31",
  "status": "active",
  "created_at": "2026-06-01T00:00:00Z",
  "progress_percent": 17.3
}
```
`ChallengeType` enum: `friday_savings | no_spend | budget_category`. `ChallengeStatus` enum:
`active | completed | cancelled | failed` — `failed` lands when a spend-based challenge is broken.
`weekly_target`/`overall_target`/`last_entry_week`/`target_category_id`/`current_period_spent` are
nullable. `current_period_spent` is only populated for `no_spend` and `budget_category`.
`progress_percent` is nullable and read-only (backend-computed).

### `ChallengeEntryResponseDto`
```json
{
  "id": "uuid",
  "amount": "5000.00",
  "verification_level": "evidence_backed",
  "note": "Payday savings",
  "file_url": null,
  "recorded_at": "2026-08-01T10:00:00Z"
}
```
`EntryVerificationLevel` enum: `self_reported | evidence_backed` — **separate from**
`ExpenseVerificationLevel`, do not reuse that model/enum for challenge entries.

### `BadgeResponseDto`
```json
{ "key": "on_fire", "name": "On Fire", "description": "9-week streak", "icon_name": "flame", "category": "streak" }
```
`icon_name` and `category` are nullable.

### `UserBadgeResponseDto`
```json
{
  "badge": { "...BadgeResponseDto" },
  "earned_period": "2026-W31",
  "earned_at": "2026-08-01T10:00:00Z"
}
```
`earned_period` is nullable.

### `DeviceTokenResponseDto`
```json
{ "id": "uuid", "platform": "ios", "is_active": true, "created_at": "2026-08-03T00:00:00Z" }
```
`DevicePlatform` enum: `ios | android | web`.

---

## Internal / Service-Only (not for the mobile client)

These exist on the backend but require an `x-api-key` service header — they are for
server-to-server email delivery, **not** the app. Do not add them to `ApiEndpoints`.

| Endpoint | Purpose |
|---|---|
| `POST /email/enqueue` | Enqueue a templated email (`to`, `subject`, `template`, `context`) |
| `GET /email/jobs/{job_id}` | Poll an enqueued email job's status |

---

## Planned / Not Yet Live

These endpoints are referenced in `ApiEndpoints` but have **not been added to the backend yet**. Do not call them until the backend confirms they exist and this file is updated.

| Endpoint | Feature |
|---|---|
| `GET /transactions` | Transaction history |

**Asked for, not yet built** (raised 2026-08-06 while working the Trello batch — each one
caps what the client can ship today):

| # | Ask | Why it's needed |
|---|---|---|
| 1 | **Income ledger** — `GET /income` returning a *paginated list*, `POST /income` creating a *new entry* each time, `DELETE /income/{id}` | Income is currently **one record per user** (`GET/POST/PATCH /income` all operate on a single `IncomeResponseDto`). So "Add income" can only ever mean *set or edit your income* — a user cannot log a second paycheck, a bonus, or side-hustle earnings as separate entries, and there is no income history to show. |
| 2 | **Invite by email or phone** — `POST /friends/invite` accepting `{email}` or `{phone}` instead of only `recipient_id`, creating a pending invite that resolves when that person registers | `SendInviteDto` takes **only `recipient_id` (a UUID)**, so you can only befriend someone who *already has an account*. There is no way to invite a non-user, which is exactly what the invite flow is for. |
| 3 | **Referral on register** — a `referral_code` / `invite_token` field on `RegisterDto`, plus resolution of that token into a pending friendship | Without it, "automatically complete the friend request after registration" is **impossible on any client**. The link survives to the store, but nothing carries the inviter's identity through install → register. |
| 4 | **`profile_icon` on every payload that names another user** — `friend_profile_icon` on `GET /friends` and `GET /friends/invites`, `profile_icon` on `GET /friends/search` results and on group member objects (`GET /groups/{id}`, `/groups/{id}/members`), and on chat message senders | `profile_icon` is returned **only by `/user/me`**, so the app can render *your own* avatar but nobody else's. Friends, group members and chat senders currently fall back to an avatar generated from their username — a stable, distinct face, but **not the one that person actually chose**. The client already parses these fields (`FriendshipModel.friendProfileIcon`, `GroupMemberModel.profileIcon`) and will use them the moment they appear; no client release is needed. |

Item 3 also needs post-install attribution on the client (Branch/AppsFlyer) — Firebase
Dynamic Links is shut down and has no free replacement. Until 1–3 land, the app ships:
set/edit income, invites that only work for existing users, and invite links that only
auto-open for recipients who **already have the app installed**.

Both previously-blocking requests shipped on 2026-08-03 — see below.

> ✅ **Attach proof to an existing expense is now live** (2026-08-03) — `PATCH /expenses/{id}`
> takes an optional `receipt` in its multipart body. `evidence_suggested` is no longer
> display-only.

> ✅ **Device-token registration is live and wired** (2026-08-03) — `/notifications/device-tokens`.

> ✅ **The in-app notification feed is live and wired** (2026-08-11) — `GET /notifications`
> and friends. The notifications screen no longer serves mock data.

> ✅ **Subscriptions are live** (2026-07-20) — under `/subscriptions/*`, not the
> previously guessed `/subscription/*`. See the Subscriptions section above.

> ✅ **Groups is no longer planned — full CRUD + friends + chat + savings are live** (2026-07-06). See the Friends and Groups (Group Savings) sections above.

> Note: there is **no `/ai/chat`** endpoint. The home AI insight is served by `GET /insights/home` (a generated string), which is what the Clara card should call.

---

## Notes for Implementation

- **`default_currency`** comes from `UserResponseDto` after login/verify-email. Pass it to `AppConfigNotifier.applyCurrency()` immediately.
- **Income sources** act as the category list for income — call `GET /income/sources` after login and cache the result.
- The backend sends `amount` as a **string** in response DTOs (e.g. `"500000.00"`). Parse with `double.tryParse()`.
- OTP codes are 6 digits. Match `AppConstants.otpLength = 6`.
- Passcodes are 6 digits. Match `AppConstants.passcodeLength = 6`.
- **`GET /expenses` does not use `ApiResponse`** — it has a top-level `pagination` object alongside `data`. Handle it with a dedicated paginated parser, not `ApiResponse.fromJson`.
- **Onboarding goals are UUIDs** — fetch `GET /goals` first, submit the selected goal `id`s to `POST /auth/onboarding/goals`.
- OCR is `POST /expenses/receipt` (multipart `image` field) — the old planned path `/expenses/ocr` never shipped.
- **Base URL changed** to `https://api.finclarai.com/api/v1` (was `finclar-ai.onrender.com`).
- **`GET /expenses/summary` and `/budgets` use numbers, not strings** for money fields — opposite of `ExpenseResponseDto`/`IncomeResponseDto` which send strings. Watch the parsing per-endpoint.
- **Home insight** (`GET /insights/home`) returns `ApiResponse<HomeInsightDto>` — an **object**, not a string (changed 2026-08-02). The sentence is `data.insight`; the figures behind it (`available_balance`, `verified_pct`, …) come along in the same call, so don't re-derive them.
- **Social auth** (`POST /auth/social`) takes a `firebase_token`; requires Firebase Auth set up on the client.
- **Show `display_name`, not `username`** — `UserResponseDto.display_name` already resolves `preferred_name` for you.
- **Both `POST /expenses` and `PATCH /expenses/{id}` are multipart, not JSON** (changed 2026-08-03) — the DTO goes in a `dto` form field as a JSON string, alongside an optional `receipt` file. `ExpenseRepository.createExpense`/`.updateExpense` already send this shape via `ApiClient.uploadFile(method: ...)`.
- **Verification levels are fully actionable** as of 2026-08-03 — attaching a receipt on `PATCH` flips an existing expense to `verified`. An "attach a receipt?" prompt on an `evidence_suggested` expense is now buildable (UI not built yet).
- **`DELETE /groups/{id}/members/{id}` requires `?redistribution=self|split`** — omitting it is a 422.
- **Wrapped is a MONTHLY recap** (changed 2026-08-03), not a year-in-review — pass `year` + `month`, and never write "this year" in client copy. Headlines are backend copy; render `headline` strings verbatim, don't compose your own.
- **Group chat pages with `page_size`, not `limit`** (changed 2026-08-03) — `limit` is silently ignored, which looks like "only 20 messages load".
