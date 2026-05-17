# Vercel deploy (Flutter web)

## Why this approach
Your Vercel build logs show: `flutter: command not found`.
So Vercel cannot run `flutter build web`.

Therefore: **build locally** and deploy the generated static files.

---

## 1) Build locally
From repo root:

```bash
flutter build web
```

This should generate:
- `build/web/*`

---

## 2) Update Vercel Project settings
In Vercel UI for this project:

- **Root Directory**: `.` (repo root — the folder containing `pubspec.yaml`)
- **Build Command**: leave empty / set to `none`
- **Output Directory**: `build/web`

Then redeploy.

---

## 3) Routing fix (already added)
Ensure `vercel.json` exists at repo root with:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

This prevents blank screens when Flutter navigates to non-`/` routes.

---

## 4) Verify
After deployment:
- Open the Vercel URL
- If it shows splash only / white screen, open browser **DevTools → Console** and check for runtime errors.

