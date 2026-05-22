# Deploy on Vercel (serverless — frontend + API)

Everything runs on **one Vercel project**: Flutter static web + Node serverless API in `/api`.

```text
Browser → your-app.vercel.app
            ├── /          → Flutter (build/web)
            └── /api/*     → Serverless functions → MongoDB Atlas
```

No separate Render server required.

---

## 1. Prerequisites

- GitHub repo connected to Vercel
- **MongoDB Atlas** connection string
- Flutter builds on Vercel via `scripts/vercel-build.sh` (Linux)

---

## 2. Vercel project settings

| Setting | Value |
|---------|--------|
| **Root Directory** | `.` (repo root) |
| **Framework Preset** | Other |
| **Build Command** | `npm run build` (from `vercel.json`) |
| **Output Directory** | `build/web` |
| **Install Command** | `npm install` |

`vercel.json` is already configured.

---

## 3. Environment variables

In **Vercel → Project → Settings → Environment Variables** (Production + Preview):

| Variable | Required | Example |
|----------|----------|---------|
| `MONGO_URI` | Yes | `mongodb+srv://user:pass@cluster.mongodb.net/language_stories` |
| `COUPON_CODE` | No | `NEER50` |
| `ADMIN_API_KEY` | Yes (for admin panel) | Long random secret |
| `NODE_ENV` | No | `production` |
| `API_BASE_URL` | No | Leave **unset** — build uses `/api` (same origin) |

Optional — only if frontend is on a **different** domain:

| Variable | Example |
|----------|---------|
| `FRONTEND_URL` | `https://my-app.vercel.app` |

---

## 4. Deploy

```bash
git push
# or
npx vercel --prod
```

First build may take **5–10 minutes** (Flutter download).

---

## 5. Verify

| URL | Expected |
|-----|----------|
| `https://YOUR-APP.vercel.app` | Flutter home |
| `https://YOUR-APP.vercel.app/api/health` | `{"status":"OK",...}` |
| `https://YOUR-APP.vercel.app/api/tenses` | JSON list of tenses |

Admin: open app → admin icon → enter `ADMIN_API_KEY`.

---

## 6. Local development

**Option A — Vercel dev (matches production)**

```bash
npm install
vercel dev
```

**Option B — Express backend + Flutter**

```powershell
.\start_backend.ps1
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000/api
```

---

## 7. API routes (serverless)

| Method | Path |
|--------|------|
| GET | `/api/health` |
| GET | `/api/tenses` |
| GET | `/api/stories?tenseId=...` |
| POST | `/api/coupon/verify` |
| POST | `/api/analytics/track` |
| GET | `/api/admin/tenses` |
| GET/POST | `/api/admin/stories` |
| PUT/DELETE | `/api/admin/stories/:id` |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| API 500 / database errors | Set `MONGO_URI`; allow `0.0.0.0/0` in Atlas Network Access |
| Empty tenses | Cold start seeds DB on first request; check function logs |
| Admin 401 | Set `ADMIN_API_KEY` in Vercel and redeploy |
| CORS errors | Use `/api` as `API_BASE_URL`; avoid cross-origin unless `FRONTEND_URL` is set |
| Build timeout | Retry deploy; consider Vercel Pro for longer builds |

---

## Legacy: Render backend

The `backend/` Express server still works for local dev. Production on Vercel uses `/api` serverless functions instead.
