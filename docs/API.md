# Finclar AI — Backend API Reference

> **Live base URL:** `https://api.finclarai.com/api/v1`
> **Swagger UI:** `https://api.finclarai.com/docs`
> **OpenAPI JSON:** `https://api.finclarai.com/openapi.json`
>
> ⚠️ Base URL changed from `finclar-ai.onrender.com` to `api.finclarai.com` (2026-06-13). Update any cached/hardcoded references.
>
> ✅ **2026-07-06:** Diffed against the live OpenAPI spec — **Friends** (search/invite/accept/decline/remove) and full **Groups** (CRUD, membership, savings entries, chat messages + attachments) are now live, plus public `POST /marketing/newsletter/subscribe` and `POST /marketing/waitlist`. None of these are wired into the app yet — see `MEMORY.md` open threads.
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

The following `GET` list endpoints return the **paginated envelope** — `data` is the array plus a sibling `pagination` object (`PaginationMeta`), just like `/expenses`. They accept `page` / `page_size` query params (chat messages use `page` / `limit`):

`/expenses`, `/categories`, `/banks`, `/banks/available`, `/income/sources`, `/goals`, `/budgets`, `/friends`, `/friends/search`, `/friends/invites`, `/groups`, `/groups/{group_id}/savings`, `/groups/{group_id}/messages`.

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
  "icon": "health"                                // optional — use keys from categoryPickerIcons
}
```

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

**Response** `PaginatedResponse<ExpenseResponseDto[]>`
```json
{
  "success": true,
  "message": null,
  "data": [ ...ExpenseResponseDto ],
  "pagination": {
    "page": 1, "page_size": 20, "total": 0,
    "total_pages": 0, "has_next": false, "has_prev": false
  }
}
```

---

#### `POST /expenses` 🔒
Create a manual expense.

**Request body**
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

**Request body** (`UpdateExpenseDto`)
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

**Response** `ApiResponse<ExpenseResponseDto>` — `source` will be `"receipt"`, `file`/`receipt_url` populated.

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

### Insights

#### `GET /insights/home` 🔒
AI-generated natural-language money insight for the home screen (the Clara card). Returns a single sentence/paragraph string.

**Response** `ApiResponse<string>`
```json
{
  "success": true,
  "message": null,
  "data": "Hey admin2002! This June, you've spent a total of ₦65,500, which is a neat 13% of your estimated income..."
}
```

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

#### `POST /groups/{group_id}/members` 🔒 — ⚠️ PLANNED, NOT YET LIVE
Add an existing finclar user to an existing group (owner only). The added user lands as `invite_status: pending` and must accept via `POST /groups/{group_id}/invite`. Needed so the owner can add friends after group creation — currently members can only be set via `member_ids` at creation. **The mobile client already calls this (`GroupRepository.addMember`); it will 404 until the backend ships it.**

**Request body**
```json
{ "recipient_id": "uuid" }
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

**Response** `ApiResponse<dict>`

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

#### `GET /groups/{group_id}/messages?page=&limit=` 🔒
Paginated group chat messages. `page` default 1; `limit` default 50, max 100.

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
  "is_active": true,
  "is_email_verified": true,
  "default_currency": "NGN",
  "created_at": "2026-01-01T00:00:00Z"
}
```

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
  "name": "Food",
  "description": "Groceries, restaurants, and food delivery."
}
```

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
  "receipt_url": null
}
```
`type`, `direction`, `status`, `currency`, `description`, `source` are all nullable. `source` is `manual | receipt | bank_sync`.

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
  "allocations": [ "AllocationResponseDto" ]
}
```
- There is **no `name`** field on a budget (removed 2026-06-22). `start_date`/`end_date`
  are always present (backend-assigned, current month).
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
- **Home insight** (`GET /insights/home`) returns `ApiResponse<string>` — the `data` is a plain AI-generated sentence, wire it directly to the Clara card.
- **Social auth** (`POST /auth/social`) takes a `firebase_token`; requires Firebase Auth set up on the client.
