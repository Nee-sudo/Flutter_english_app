# Deploy on Vercel (serverless full stack)

See **[VERCEL_DEPLOY.md](./VERCEL_DEPLOY.md)** for the complete guide.

## Quick setup

1. Push this repo to GitHub and import in [Vercel](https://vercel.com).
2. `vercel.json` builds Flutter → `build/web` and deploys `/api/*` serverless functions.
3. Set environment variables in Vercel:

   | Name | Required |
   |------|----------|
   | `MONGO_URI` | Yes |
   | `ADMIN_API_KEY` | Yes (admin panel) |
   | `COUPON_CODE` | No (default `NEER50`) |

   Leave `API_BASE_URL` **unset** — the app uses same-origin `/api`.

5. Deploy. First build may take several minutes while Flutter is downloaded.

## Optional: deploy from CLI

```bash
npm i -g vercel
vercel
# production:
vercel --prod
```

Set `API_BASE_URL` in the Vercel project **Settings → Environment Variables** before promoting to production.

## Local production build (same as Vercel)

```bash
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.example.com/api
```

Serve `build/web` with any static host, or use `.\serve_web.ps1` on Windows.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `flutter: command not found` in logs | Ensure `vercel.json` uses `npm run build`, not `flutter build` directly. |
| Blank page after load | Check browser console; confirm `vercel.json` rewrites are present. |
| Coupon/API fails in production | Set `API_BASE_URL` in Vercel env vars and redeploy. |
| Build timeout | Upgrade plan or retry; first Flutter install is slow. |
