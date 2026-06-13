# Finclar AI — Backend API Reference

> **Live base URL:** `https://finclar-ai.onrender.com/api/v1`
> **Swagger UI:** `https://finclar-ai.onrender.com/docs`
> **OpenAPI JSON:** `https://finclar-ai.onrender.com/openapi.json`
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

Live data (10): Education, Entertainment, Food, Health, Investment, Other, Rent, Shopping, Transportation, Utilities — each with `id` (uuid), `name`, `description`.

---

### Expenses

#### `GET /expenses` 🔒
Paginated, filterable expense list. **Note: this is the only endpoint that does NOT use the standard `ApiResponse` envelope — it returns `PaginatedResponse`.**

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

**Request body**
```json
{
  "amount": 3000,
  "description": "Updated",
  "category_ids": ["uuid"],
  "expense_date": "2026-06-13T10:00:00Z",
  "currency": "NGN",
  "status": "completed"
}
```

**Response** `ApiResponse<ExpenseResponseDto>`

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

#### `DELETE /banks/{bank_id}` 🔒
Disconnect a linked bank.

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

---

## Planned / Not Yet Live

These endpoints are referenced in `ApiEndpoints` but have **not been added to the backend yet**. Do not call them until the backend confirms they exist and this file is updated.

| Endpoint | Feature |
|---|---|
| `GET /budgets` | Budget list |
| `POST /budgets` | Create budget |
| `GET /groups` | Group savings list |
| `POST /groups` | Create group |
| `GET /transactions` | Transaction history |
| `POST /ai/chat` | Clara AI chat |
| `GET /ai/chat/history` | Chat history |
| `GET /subscription/plans` | Subscription plans |
| `POST /subscription` | Subscribe |

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
