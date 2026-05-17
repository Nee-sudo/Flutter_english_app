# Deploy Flutter web on Vercel

## One-time setup

1. Push this repo to GitHub (or GitLab / Bitbucket).
2. In [Vercel](https://vercel.com), **Add New Project** and import the repository.
3. Vercel reads `vercel.json` automatically:
   - **Build command:** `npm run build` (installs Flutter on Linux, then `flutter build web`)
   - **Output directory:** `build/web`
4. Add an environment variable (Production + Preview):

   | Name | Example |
   |------|---------|
   | `API_BASE_URL` | `https://your-backend.example.com/api` |

   Leave unset only for local-style testing; coupon/analytics calls need a reachable backend.

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
