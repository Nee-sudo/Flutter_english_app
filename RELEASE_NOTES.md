# Release Notes — Language Stories

**Version:** 1.0.0 (build 1)  
**Release date:** May 16, 2026  
**Package name:** `language_stories_app`

---

## Overview

**Language Stories** is a mobile-responsive Flutter web application for learning English verb tenses through bilingual (English / Hindi) short stories. Learners explore four core tenses on the home screen, read free demo stories, and unlock premium stories with a coupon code. Unlock state persists in the browser; an optional Node.js backend validates coupons and tracks analytics in MongoDB.

This is the **initial production-ready release** of the full stack (Flutter frontend + Express API).

---

## Highlights

- Four English tenses with **8 stories** (1 demo + 1 premium per tense)
- **Bilingual reader** — toggle English and Hindi on any unlocked story
- **Freemium model** — demo stories free; premium gated behind coupon `NEER50`
- **Offline-capable unlock** — coupon works even when the API is unreachable
- **Responsive UI** — optimized layouts for mobile and desktop
- **Optional backend** — coupon verification and user analytics via REST API

---

## New in 1.0.0

### Application features

| Feature | Description |
|--------|-------------|
| Home screen | Grid of tense cards with emoji, title, and short description |
| Story browser | Per-tense list of stories with demo / locked indicators |
| Story reader | Full story text with English / Hindi toggle |
| Paywall modal | Bottom sheet to enter a coupon and unlock all premium content |
| Unlock banner | Status bar showing demo-only vs premium-unlocked state |
| Session persistence | User ID and unlock state saved via `shared_preferences` (web: local storage) |

### Content (v1.0.0)

| Tense | Demo story | Premium story |
|-------|------------|---------------|
| Present Simple | Daily Routine | The Student's Day |
| Past Continuous | Yesterday's Event | The Unexpected Visit |
| Future Perfect | Future Plans | Success Story |
| Present Perfect Continuous | Ongoing Activity | Life Journey |

All story copy is bundled in the client (`ApiService` mock data) so the app runs without a stories API.

### Backend API (v1.0.0)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/` | Health / welcome JSON |
| `GET` | `/api/health` | Server status |
| `POST` | `/api/coupon/verify` | Validate coupon code |
| `POST` | `/api/analytics/track` | Record unique unlocked user (MongoDB) |

Default coupon: **`NEER50`** (configurable via `COUPON_CODE` in `backend/.env`).

### Tooling & scripts

| Script | Purpose |
|--------|---------|
| `start_backend.ps1` | Install deps (if needed), ensure `.env`, start API on port 5000 |
| `start_app.ps1` | `flutter pub get` + `flutter run -d chrome` on port 8080 |
| `serve_web.ps1` | Build if missing, copy web assets, serve `build/web` on port 8080 |

### Quality & stability fixes (included in 1.0.0)

- **pubspec.yaml** — Removed invalid `assets:` block that caused analyzer warnings
- **Coupon flow** — 8s HTTP timeout, safer JSON parsing, offline fallback for `NEER50`
- **Web hosting** — Added `web/manifest.json`; `index.html` uses `flutter_bootstrap.js` (current Flutter web loader)
- **Tests** — `test/api_service_test.dart` (tenses, stories, coupon)
- **Backend** — Clearer MongoDB connection errors; analytics returns 503 when DB unavailable (coupon API still works)
- **Project hygiene** — `.gitignore`, `backend/.env.example` (secrets not committed)

---

## User experience

### First visit

1. App loads the home screen with four tense cards.
2. Unlock banner shows: *“Demo stories only. Enter coupon to unlock.”*
3. User taps a tense → story list opens (demo story selected by default).

### Reading stories

- **Demo stories** — Always readable.
- **Premium stories** — Show a lock icon; tapping opens the paywall.
- **Language toggle** — “English” / “हिंदी” buttons switch story body text.

### Unlocking premium

1. Tap a locked story → **Premium Content** modal.
2. Enter coupon **`NEER50`** (case-insensitive).
3. On success: snackbar confirmation, modal closes, all stories unlock.
4. Refresh the page — unlock state remains (local storage).

### Desktop vs mobile

- **Mobile** (`< 600px`): Single-column tense grid; story list stacked above reader.
- **Desktop**: Two-column tense grid; story list sidebar + reader panel.

---

## Technical details

### Frontend

| Item | Value |
|------|--------|
| Framework | Flutter (SDK ≥ 3.0.0) |
| Target | Web (Chrome recommended) |
| State management | `provider` (`AppStateProvider`) |
| HTTP | `http` package |
| Local storage | `shared_preferences` |
| IDs | `uuid` v4 per user |
| UI | Material 3, custom color palette (`AppColors`) |

**Key source locations**

- `lib/main.dart` — App entry, theme, `HomeScreen`
- `lib/screens/home_screen.dart` — Tense grid
- `lib/screens/story_view_screen.dart` — Story list + reader
- `lib/widgets/paywall_modal.dart` — Coupon UI
- `lib/widgets/story_display.dart` — Bilingual reader
- `lib/services/api_service.dart` — Mock content + API + offline coupon
- `lib/services/state_provider.dart` — App state
- `lib/utils/constants.dart` — Colors, spacing, API URLs, `NEER50`

**API base URL (frontend):** `http://localhost:5000/api`

### Backend

| Item | Value |
|------|--------|
| Runtime | Node.js (ES modules) |
| Framework | Express 4.x |
| Database | MongoDB (Mongoose 7.x) — required for analytics only |
| Default port | `5000` |

**Environment variables** (`backend/.env`)

| Variable | Description |
|----------|-------------|
| `MONGO_URI` | MongoDB connection string |
| `PORT` | Server port (default `5000`) |
| `COUPON_CODE` | Valid coupon (default `NEER50`) |
| `NODE_ENV` | e.g. `development` |

---

## System requirements

### To run the Flutter app

- Flutter SDK ≥ 3.0.0 with web support enabled
- Chrome (or another supported browser for `flutter run -d chrome`)
- Windows / macOS / Linux dev environment

### To run the full stack

- Node.js ≥ 16.x
- MongoDB (local or Atlas) — optional for UI-only + offline coupon; required for analytics persistence

---

## Installation & run

### Quick start (recommended)

**Terminal 1 — Backend (optional but recommended for live coupon + analytics)**

```powershell
cd Project_31_Flutter_notes
.\start_backend.ps1
```

**Terminal 2 — Flutter web**

```powershell
cd Project_31_Flutter_notes
.\start_app.ps1
```

### Static build (production preview)

```powershell
flutter build web --no-wasm-dry-run
.\serve_web.ps1
```

Open **http://localhost:8080** (must serve from `build/web`, not project root).

### Verify quality

```powershell
flutter analyze
flutter test test/api_service_test.dart
```

---

## Known limitations

1. **Stories are client-side mocks** — Tenses and stories are not loaded from the backend API in v1.0.0; only coupon and analytics use the server.
2. **Web-only in practice** — Project is configured for web; mobile/desktop targets are not validated in this release.
3. **Coupon in client** — Offline fallback embeds `NEER50` in app constants; treat as demo/education use, not high-security DRM.
4. **First `flutter test` run** — Can take several minutes on first compile on Windows.
5. **Harmless 404s when serving statically** — `flutter.js.map` and Chrome DevTools probe URLs may 404; they do not affect app behavior.
6. **Analytics** — If MongoDB is down, unlock still works; tracking may return 503.

---

## Security & privacy notes

- Do **not** commit `backend/.env` (listed in `.gitignore`).
- Use `backend/.env.example` as a template for new environments.
- Each browser session gets a random `userId` (UUID) stored locally.
- Analytics endpoint receives `userId`, `ipAddress`, and `user-agent` when unlock succeeds and the backend is reachable.

---

## Upgrade / migration

This is the first release — no migration steps.

**From a dev preview build:**

1. Pull latest code.
2. `flutter pub get`
3. `cd backend && npm install`
4. Rebuild web: `flutter build web --no-wasm-dry-run`
5. Clear browser storage if testing unlock from scratch (DevTools → Application → Local Storage).

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Blank page / stuck on “Loading…” | Serve from `build/web`; ensure `index.html` loads `flutter_bootstrap.js` |
| `manifest.json` 404 | Run `.\serve_web.ps1` or copy `web/manifest.json` to `build/web` |
| Coupon always fails | Start backend **or** use `NEER50` (offline mode after timeout) |
| `flutter test` timeout | Use `test/api_service_test.dart` only (no widget tests in v1.0.0) |
| MongoDB errors in backend console | Coupon still works; fix `MONGO_URI` for analytics |

---

## Credits & license

Educational project — **KJC college work**, Project 31 (Flutter notes).

---

## [v1.0.0]

## Version history

| Version | Build | Date | Summary |
|---------|-------|------|---------|
| **1.0.0** | 1 | 2026-05-16 | Initial release: 4 tenses, 8 stories, coupon paywall, bilingual reader, Node API, offline coupon fallback, web hosting fixes |

---

*For setup details, see `SETUP.md` and `QUICK_START.md`.*
