# Flutter Language Stories App - Complete Implementation Guide

## Setup Instructions

### Step 1: Create Directory Structure
```
Project_31_Flutter_notes/
├── pubspec.yaml (already exists)
├── lib/
│   ├── main.dart
│   ├── utils/
│   │   └── constants.dart
│   ├── models/
│   │   ├── tense_model.dart
│   │   ├── story_model.dart
│   │   └── user_state_model.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── story_view_screen.dart
│   ├── widgets/
│   │   ├── tense_card.dart
│   │   ├── story_card.dart
│   │   ├── paywall_modal.dart
│   │   └── story_display.dart
│   └── services/
│       ├── api_service.dart
│       ├── storage_service.dart
│       └── state_provider.dart
├── web/
│   └── index.html
└── backend/
    ├── src/
    │   ├── server.js
    │   ├── routes/
    │   │   ├── coupon.routes.js
    │   │   └── analytics.routes.js
    │   ├── controllers/
    │   │   ├── coupon.controller.js
    │   │   └── analytics.controller.js
    │   ├── models/
    │   │   └── schemas.js
    │   ├── middleware/
    │   │   └── errorHandler.js
    │   └── config/
    │       └── database.js
    ├── .env
    ├── .env.example
    └── package.json
```

### Step 2: Install Flutter Dependencies
```bash
cd Project_31_Flutter_notes
flutter pub get
```

### Step 3: Setup Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your MongoDB URI
npm start
```

### Step 4: Run Flutter Web App
```bash
cd ..
flutter run -d web
```

## API Endpoints

### Verify Coupon
- **POST** `/api/coupon/verify`
- Body: `{ "coupon": "NEER50" }`
- Response: `{ "valid": true, "message": "Coupon verified" }`

### Track User
- **POST** `/api/analytics/track`
- Body: `{ "userId": "uuid", "ipAddress": "x.x.x.x" }`
- Response: `{ "success": true, "totalUsers": 42 }`

## Demo Content
- Present Simple: 1 demo story
- Past Continuous: 1 demo story
- Future Perfect: 1 demo story
- Present Perfect Continuous: 1 demo story

## Testing the App
1. Open app, see all tenses
2. Click a tense, see stories (demo accessible, others locked)
3. Try to view a locked story → paywall modal appears
4. Enter "NEER50" → all stories unlock
5. Refresh page → stories remain unlocked (persisted in localStorage)
