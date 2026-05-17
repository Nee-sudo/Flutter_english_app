# 🚀 Flutter Language Stories App - Quick Start Guide

## Overview
This is a complete full-stack application for learning English tenses through interactive stories. The app features:
- ✅ Free demo stories for each tense
- ✅ Premium content unlocked with coupon code (NEER50)
- ✅ Session persistence using localStorage
- ✅ User analytics tracking
- ✅ Fully responsive mobile-first design

---

## 📋 Project Structure

```
Project_31_Flutter_notes/
├── pubspec.yaml                    # Flutter dependencies
├── lib/
│   ├── main.dart                   # App entry point
│   ├── utils/
│   │   └── constants.dart          # Colors, spacing, API URLs
│   ├── models/
│   │   ├── tense_model.dart
│   │   ├── story_model.dart
│   │   └── user_state_model.dart
│   ├── screens/
│   │   ├── home_screen.dart        # Tenses list view
│   │   └── story_view_screen.dart  # Stories and content view
│   ├── widgets/
│   │   ├── tense_card.dart
│   │   ├── story_display.dart
│   │   └── paywall_modal.dart      # Coupon modal
│   └── services/
│       ├── storage_service.dart    # localStorage management
│       ├── api_service.dart        # API calls
│       └── state_provider.dart     # State management
├── web/
│   └── index.html
├── backend/                        # Node.js server
│   ├── src/
│   │   ├── server.js
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── middleware/
│   │   └── config/
│   ├── package.json
│   └── .env
└── Documentation files
```

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- MongoDB (local or Atlas)
- VS Code or Android Studio

### Step 1: Setup Flutter Frontend

```bash
# Navigate to project directory
cd Project_31_Flutter_notes

# Install Flutter dependencies
flutter pub get

# Run on web (default port: 5000)
flutter run -d web
```

**Troubleshooting**:
- If Flutter web not available: `flutter config --enable-web`
- Clear cache: `flutter clean && flutter pub get`

### Step 2: Setup Node.js Backend

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your MongoDB connection string
# MONGO_URI=mongodb://localhost:27017/language_stories

# Start server
npm start
```

**Backend will run on**: `http://localhost:5000`

### Step 3: Update API Base URL

If your backend runs on a different port, update in `lib/utils/constants.dart`:

```dart
class AppAPI {
  static const String baseUrl = 'http://localhost:YOUR_PORT/api';
  // ...
}
```

---

## 📱 Feature Walkthrough

### Homepage (home_screen.dart)
- Displays 4 tenses with cards
- Shows unlock status (locked/unlocked)
- Tappable cards navigate to story view

### Story View (story_view_screen.dart)
- Lists all stories for selected tense
- First story is always "Demo" (free)
- Locked stories show lock icon
- Clicking locked story opens paywall modal

### Paywall Modal (paywall_modal.dart)
- Text field for coupon code entry
- Hint: "Try NEER50 for access"
- Verifies code via backend API
- Updates app state on success
- State persists in localStorage

### Story Display (story_display.dart)
- English/Hindi toggle buttons
- Full story text with good readability
- Responsive font sizing for mobile/desktop

---

## 🔐 How Coupon System Works

### Frontend Flow
1. User clicks locked story → paywall modal opens
2. User enters coupon: **NEER50**
3. Frontend calls: `POST /api/coupon/verify`
4. Backend responds: `{ valid: true, message: "..." }`
5. Frontend saves `isUnlocked: true` to localStorage
6. User ID (UUID) generated and sent to backend
7. Analytics updated on backend

### Backend Logic
- Coupon verification: Simple string match (NEER50)
- User tracking: Saves user ID, timestamp, IP address
- Analytics: Updates total unlock count in MongoDB

### Session Persistence
- Uses Flutter's `shared_preferences` (which maps to localStorage for web)
- Key: `unlocked_state` stores JSON: `{ userId, isUnlocked, unlockedAt }`
- Persists across page refreshes and browser restarts

---

## 📊 Database Schema (MongoDB)

### Collections

**Tenses**
```javascript
{
  _id: ObjectId,
  name: "Present Simple",
  description: "Habitual actions and facts",
  emoji: "⏰",
  createdAt: Date
}
```

**Stories**
```javascript
{
  _id: ObjectId,
  tenseId: ObjectId,
  title: "Demo: Daily Routine",
  englishText: "I wake up at 7 AM...",
  hindiText: "मैं सुबह 7 बजे जागता हूँ...",
  isDemo: true,
  createdAt: Date
}
```

**Users**
```javascript
{
  _id: ObjectId,
  userId: "uuid-string",
  couponAppliedAt: Date,
  ipAddress: "x.x.x.x",
  userAgent: "Mozilla/5.0...",
  createdAt: Date
}
```

**Analytics**
```javascript
{
  _id: ObjectId,
  totalUnlockedUsers: 42,
  totalCouponAttempts: 150,
  lastUpdated: Date
}
```

---

## 🧪 Testing the App

### Test Scenario 1: View Demo Stories
1. Open app → Click "Present Simple"
2. See "Demo: Daily Routine" story
3. Click it → Can read full content without unlock
4. ✅ Demo accessible

### Test Scenario 2: Try to View Premium Story
1. Click "Past Continuous"
2. Click "The Unexpected Visit" (non-demo)
3. See paywall modal
4. Enter wrong code "TEST123"
5. Get error message "Invalid coupon code"
6. ✅ Validation works

### Test Scenario 3: Unlock with Correct Code
1. In paywall modal, enter "NEER50"
2. See success message "✨ All stories unlocked!"
3. Modal closes
4. All stories now accessible
5. ✅ Unlock works

### Test Scenario 4: Session Persistence
1. After unlocking, refresh browser (F5)
2. Stories still unlocked
3. Check localStorage: `unlocked_state` exists
4. ✅ Session persisted

### Test Scenario 5: Analytics Tracking
1. After first unlock, check MongoDB
2. `users` collection has new entry
3. `analytics.totalUnlockedUsers` incremented
4. ✅ Analytics work

---

## 🎨 UI/UX Features

### Responsive Design
- **Mobile** (<600px): Single column, vertical layout
- **Tablet** (600-900px): 2-column grid
- **Desktop** (>900px): Sidebar + content layout

### Colors (Consistent Across App)
- Primary: `#6366F1` (Indigo)
- Secondary: `#10B981` (Green)
- Accent: `#EC4899` (Pink)
- Background: `#F8F9FA` (Light Gray)
- Locked: `#FCD34D` (Yellow)

### Typography
- Headings: Bold, 24-28px
- Body: Regular, 14-16px
- High contrast ratios for accessibility

---

## 🚨 Common Issues & Fixes

### Issue 1: CORS Error
**Error**: "Access to XMLHttpRequest denied"
**Solution**: Backend has CORS enabled. Check backend is running.

### Issue 2: MongoDB Connection Failed
**Error**: "Cannot connect to MongoDB"
**Solution**: 
```bash
# Ensure MongoDB is running:
mongod

# Update .env MONGO_URI if using MongoDB Atlas:
MONGO_URI=mongodb+srv://user:password@cluster.mongodb.net/language_stories
```

### Issue 3: Coupon Not Working
**Error**: "Invalid coupon code"
**Solution**: 
- Check backend .env: `COUPON_CODE=NEER50`
- Restart backend after .env change
- Verify API response: `curl http://localhost:5000/api/coupon/verify -X POST -H "Content-Type: application/json" -d '{"coupon":"NEER50"}'`

### Issue 4: Stories Not Loading
**Error**: "Blank stories list"
**Solution**:
- Check browser console for errors
- Verify backend is running and accessible
- Check API URL in `lib/utils/constants.dart`
- Try: `curl http://localhost:5000/api/health`

---

## 📦 Deployment

### Deploy Flutter Web
```bash
# Build for production
flutter build web --release

# Output: build/web/
# Deploy to: Vercel, Netlify, Firebase Hosting, etc.
```

### Deploy Node.js Backend
Option 1: Heroku
```bash
git init
git add .
git commit -m "Initial commit"
heroku create your-app-name
git push heroku main
```

Option 2: Railway/Render/DigitalOcean
- Connect GitHub repo
- Set environment variables
- Deploy on push

### Connect Deployed Services
- Update `AppAPI.baseUrl` to deployed backend URL
- Rebuild Flutter web with new URL

---

## 📝 Demo Content Included

### Tense 1: Present Simple (⏰)
- Demo: "Daily Routine"
- Premium: "The Student's Day"

### Tense 2: Past Continuous (📚)
- Demo: "Yesterday's Event"
- Premium: "The Unexpected Visit"

### Tense 3: Future Perfect (🚀)
- Demo: "Future Plans"
- Premium: "Success Story"

### Tense 4: Present Perfect Continuous (🔄)
- Demo: "Ongoing Activity"
- Premium: "Life Journey"

---

## 🔗 API Endpoints

### Verify Coupon
```
POST /api/coupon/verify
Content-Type: application/json

{
  "coupon": "NEER50"
}

Response (200):
{
  "valid": true,
  "message": "Coupon code is valid. All stories unlocked!"
}

Response (400):
{
  "valid": false,
  "message": "Invalid coupon code. Please try again."
}
```

### Track User
```
POST /api/analytics/track
Content-Type: application/json

{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "ipAddress": "192.168.1.1"
}

Response (200):
{
  "success": true,
  "message": "User tracked successfully",
  "totalUsers": 42
}
```

### Get Analytics
```
GET /api/analytics/stats

Response (200):
{
  "success": true,
  "data": {
    "totalUnlockedUsers": 42,
    "totalUsers": 42,
    "lastUpdated": "2024-05-16T11:30:00.000Z"
  }
}
```

### Health Check
```
GET /api/health

Response (200):
{
  "status": "OK",
  "message": "Server is running"
}
```

---

## 📚 File Reference Quick Links

**Frontend Models**
- `lib/models/tense_model.dart` - Tense data structure
- `lib/models/story_model.dart` - Story data structure  
- `lib/models/user_state_model.dart` - User session state

**Frontend Services**
- `lib/services/storage_service.dart` - localStorage management
- `lib/services/api_service.dart` - API communication
- `lib/services/state_provider.dart` - Global state management

**Frontend UI**
- `lib/screens/home_screen.dart` - Main tenses list
- `lib/screens/story_view_screen.dart` - Story details page
- `lib/widgets/paywall_modal.dart` - Coupon entry modal

**Backend Routes**
- `backend/src/routes/coupon.routes.js` - Coupon endpoints
- `backend/src/routes/analytics.routes.js` - Analytics endpoints

**Backend Controllers**
- `backend/src/controllers/coupon.controller.js` - Coupon logic
- `backend/src/controllers/analytics.controller.js` - Analytics logic

---

## 🎯 Next Steps

1. ✅ Copy all files from COMPLETE_CODE_BUNDLE.md
2. ✅ Install Flutter & Node.js dependencies
3. ✅ Setup MongoDB (local or Atlas)
4. ✅ Run backend server (`npm start`)
5. ✅ Run Flutter web app (`flutter run -d web`)
6. ✅ Test coupon code (NEER50)
7. ✅ Deploy both frontend and backend

---

## 💡 Tips & Tricks

- **For debugging**: Enable verbose logging in backend and Flutter
- **For styling**: All colors/spacing in `lib/utils/constants.dart`
- **For new stories**: Add directly to mock data in `api_service.dart` or database
- **For new tenses**: Update mock data in `getTenses()` method
- **For testing without backend**: Comment out API calls and use mock data

---

## 🆘 Support

For issues or questions, check:
1. Console errors (F12 in browser)
2. Backend logs (terminal running `npm start`)
3. MongoDB connection string
4. CORS and firewall settings
5. API endpoint accessibility

---

**Built with ❤️ using Flutter & Node.js**
