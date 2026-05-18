# Admin API — add premium English / Hindi stories

Protected by `ADMIN_API_KEY` on the server (Render env var).

Send the key on every admin request:

```http
X-Admin-Key: YOUR_ADMIN_API_KEY
```

or

```http
Authorization: Bearer YOUR_ADMIN_API_KEY
```

Base URL: `https://YOUR-RENDER-HOST.onrender.com/api/admin`

---

## 1. List tenses (get `tenseId` for new stories)

```http
GET /api/admin/tenses
X-Admin-Key: YOUR_KEY
```

Response:

```json
{
  "success": true,
  "data": [
    { "_id": "665a...", "name": "Present Simple", "description": "...", "emoji": "⏰" }
  ]
}
```

Public equivalent (no key): `GET /api/tenses`

---

## 2. Add premium story

```http
POST /api/admin/stories
Content-Type: application/json
X-Admin-Key: YOUR_KEY

{
  "tenseId": "665a1f77bcf86cd799439011",
  "title": "A Day at the Market",
  "englishText": "She walks to the market every Sunday...",
  "hindiText": "वह हर रविवार बाज़ार जाती है...",
  "isDemo": false
}
```

- `isDemo: false` → premium (requires coupon unlock in the app)
- `isDemo: true` → free demo story

---

## 3. List all stories (admin)

```http
GET /api/admin/stories
GET /api/admin/stories?tenseId=665a1f77bcf86cd799439011
X-Admin-Key: YOUR_KEY
```

---

## 4. Update English / Hindi text

```http
PUT /api/admin/stories/STORY_ID
Content-Type: application/json
X-Admin-Key: YOUR_KEY

{
  "englishText": "Updated English paragraph...",
  "hindiText": "अपडेटेड हिंदी पाठ..."
}
```

You can also update `title`, `isDemo`, or `tenseId`.

---

## 5. Delete a story

```http
DELETE /api/admin/stories/STORY_ID
X-Admin-Key: YOUR_KEY
```

---

## App reads new content

The Flutter app loads stories from:

- `GET /api/tenses`
- `GET /api/stories?tenseId=...`

After adding stories in MongoDB, users refresh the Vercel site to see new premium content (no frontend redeploy needed).

---

## Render setup

Add environment variable:

| Variable | Example |
|----------|---------|
| `ADMIN_API_KEY` | long random string (e.g. from `openssl rand -hex 32`) |
| `MONGO_URI` | MongoDB Atlas connection string |

On first connect with an empty database, the server seeds the original demo + premium stories automatically.
