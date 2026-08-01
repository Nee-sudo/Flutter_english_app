# TODO — Fix Vercel Serverless Function Limit

**Problem:** Vercel Hobby plan allows max 12 serverless functions. The `/api` folder has 14 `.js` files (10 endpoints + 4 shared helpers in `api/lib/`), and Vercel counts every `.js` file under `/api`.

**Fix:** Rename `api/lib/` → `api/_lib/` (Vercel ignores underscore-prefixed files/folders when counting functions) and update all import paths.

## Steps

- [x] 1. Analyze task & read relevant files
- [x] 2. Confirm plan with user
- [x] 3. Create TODO.md
- [x] 4. Rename `api/lib/` → `api/_lib/`
- [x] 5. Update imports in `api/health.js`, `api/stories.js`, `api/tenses.js`
- [x] 6. Update imports in `api/admin/stories.js`, `api/admin/tenses.js`, `api/admin/stories/[id].js`
- [x] 7. Update imports in `api/analytics/track.js`, `api/coupon/verify.js`
- [x] 8. Update imports in `api/pdf/generate.js`, `api/pdf/download/[token].js`
- [x] 9. Verify no remaining `lib/` references and confirm final endpoint count (< 12)
- [x] 10. Report before/after counts and list of edited files

