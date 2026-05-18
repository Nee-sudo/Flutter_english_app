# Render — backend only

Frontend is on **Vercel**. Use Render only for the Node API.

## Service settings

| Setting | Value |
|---------|--------|
| **Root Directory** | `backend` |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |

Do **not** use `npm run build` on this service.

## Environment variables

See `backend/.env.example` and [DEPLOYMENT.md](./DEPLOYMENT.md).

Required for production: `MONGO_URI`, `COUPON_CODE`, `FRONTEND_URL` (your Vercel URL).

Then point Vercel `API_BASE_URL` at `https://<your-render-host>/api`.
