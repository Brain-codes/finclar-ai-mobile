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
Save the user's selected financial goals during onboarding.

**Request body**
```json
{
  "goals": ["save_more", "track_expenses", "budget_better"]
}
```

**Response** `ApiResponse<dict>`

---

### User

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

---

## Planned / Not Yet Live

These endpoints are referenced in `ApiEndpoints` but have **not been added to the backend yet**. Do not call them until the backend confirms they exist and this file is updated.

| Endpoint | Feature |
|---|---|
| `GET /expenses` | Expenses list |
| `POST /expenses` | Add manual expense |
| `GET /expenses/:id` | Single expense |
| `PATCH /expenses/:id` | Edit expense |
| `DELETE /expenses/:id` | Delete expense |
| `POST /expenses/ocr` | OCR receipt scan |
| `GET /budgets` | Budget list |
| `POST /budgets` | Create budget |
| `GET /groups` | Group savings list |
| `POST /groups` | Create group |
| `GET /transactions` | Transaction history |
| `POST /ai/chat` | Clara AI chat |
| `GET /ai/chat/history` | Chat history |
| `GET /subscription/plans` | Subscription plans |
| `POST /subscription` | Subscribe |
| `GET /categories` | Expense categories |

---

## Notes for Implementation

- **`default_currency`** comes from `UserResponseDto` after login/verify-email. Pass it to `AppConfigNotifier.applyCurrency()` immediately.
- **Income sources** act as the category list for income — call `GET /income/sources` after login and cache the result.
- The backend sends `amount` as a **string** in response DTOs (e.g. `"500000.00"`). Parse with `double.tryParse()`.
- OTP codes are 6 digits. Match `AppConstants.otpLength = 6`.
- Passcodes are 6 digits. Match `AppConstants.passcodeLength = 6`.
