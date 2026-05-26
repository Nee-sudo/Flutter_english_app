import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import couponRoutes from './routes/coupon.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';
import contentRoutes from './routes/content.routes.js';
import adminRoutes from './routes/admin.routes.js';
import pdfRoutes from './routes/pdf.routes.js';
import { seedIfEmpty } from './seed/seedDatabase.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// CORS: Flutter web dev uses a random port each run (e.g. :55675).
// In development, allow any localhost / 127.0.0.1 origin.
// In production, set FRONTEND_URL to a comma-separated allowlist.
const isProduction = process.env.NODE_ENV === 'production';
const configuredOrigins = process.env.FRONTEND_URL
  ? process.env.FRONTEND_URL.split(',').map((o) => o.trim()).filter(Boolean)
  : [];

const localhostOrigin =
  /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

app.use(
  cors({
    origin(origin, callback) {
      // Same-origin or server-to-server (curl, health checks)
      if (!origin) {
        return callback(null, true);
      }

      if (configuredOrigins.includes(origin)) {
        return callback(null, true);
      }

      if (!isProduction && localhostOrigin.test(origin)) {
        return callback(null, true);
      }

      console.warn(`CORS blocked origin: ${origin}`);
      return callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Admin-Key'],
  })
);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const mongoUri =
  process.env.MONGO_URI || 'mongodb://localhost:27017/language_stories';

mongoose
  .connect(mongoUri, { serverSelectionTimeoutMS: 5000 })
  .then(async () => {
    console.log('✅ MongoDB connected');
    await seedIfEmpty();
  })
  .catch((err) => {
    console.log('⚠️ MongoDB unavailable:', err.message);
    console.log('   Coupon API still works; content/admin APIs need MongoDB.');
  });

app.use('/api/coupon', couponRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/pdf', pdfRoutes);
app.use('/api', contentRoutes);
app.use('/api/admin', adminRoutes);

app.get('/', (req, res) => {
  res.json({ status: 'OK', message: 'Language Stories backend running' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});


app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
