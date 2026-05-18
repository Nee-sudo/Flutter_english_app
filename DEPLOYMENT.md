# Production: Vercel (frontend) + Render (backend)

## Architecture

```text
Browser → Vercel (Flutter web) → Render (Node API) → MongoDB Atlas
```

---

## 1. Render — backend (Web Service)

| Setting | Value |
|---------|--------|
| **Root Directory** | `backend` |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |

**Environment variables** (Render → your service → Environment):

| Variable | Example |
|----------|---------|
| `MONGO_URI` | `mongodb+srv://user:pass@cluster.mongodb.net/language_stories` |
| `COUPON_CODE` | `NEER50` |
| `NODE_ENV` | `production` |
| `FRONTEND_URL` | `https://your-app.vercel.app` |
| `ADMIN_API_KEY` | Long random secret for adding premium stories (see [ADMIN_API.md](./ADMIN_API.md)) |

- `PORT` is set automatically by Render — do not override.
- `FRONTEND_URL`: your live Vercel URL(s), comma-separated if you have preview + production domains. Omit locally (CORS allows all in dev).

After deploy, note the API URL, e.g. `https://language-stories-api.onrender.com`.

**Smoke test:**

```text
https://YOUR-SERVICE.onrender.com/api/health
```

Should return `{"status":"OK",...}`.

---

## 2. Vercel — frontend (Static / Flutter build)

Root directory: **repo root** (where `pubspec.yaml` is).

`vercel.json` already sets build output to `build/web`.

**Environment variable** (Vercel → Project → Settings → Environment Variables):

| Variable | Value |
|----------|--------|
| `API_BASE_URL` | `https://YOUR-SERVICE.onrender.com/api` |

Use your real Render hostname. Must include `/api` at the end, no trailing slash after `api`.

Apply to **Production** (and **Preview** if you want preview deploys to hit the same API).

**Redeploy** Vercel after adding or changing `API_BASE_URL` — it is baked in at build time via `--dart-define`.

---

## 3. Connect the two

1. Deploy backend on Render → copy `https://….onrender.com`.
2. Set Vercel `API_BASE_URL` = `https://….onrender.com/api`.
3. Set Render `FRONTEND_URL` = your Vercel URL (e.g. `https://my-app.vercel.app`).
4. Redeploy **both** if you change URLs or env vars.

---

## 4. Verify in the browser

1. Open the Vercel site.
2. DevTools → **Network**.
3. Unlock with coupon `NEER50` → should see `POST` to `https://….onrender.com/api/coupon/verify` (status 200).

If coupon works offline but not online, `API_BASE_URL` was not set or Vercel was not redeployed after setting it.

---

## 5. Common issues

| Problem | Fix |
|---------|-----|
| CORS error in browser console | Set `FRONTEND_URL` on Render to exact Vercel origin (scheme + host, no path). Redeploy API. |
| `localhost:5000` in Network tab | Redeploy Vercel with `API_BASE_URL` set. |
| API 502 / timeout on free tier | Render free services spin down; first request may take ~30s. |
| Analytics not saving | Set `MONGO_URI` on Render; check logs for MongoDB connection. |
| Render build: Missing script `build` | Root Directory must be `backend`, not repo root. No `npm run build` on API service. |

---

## Local development

```bash
# Terminal 1
cd backend && npm start

# Terminal 2
flutter run -d web
# or
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
```
