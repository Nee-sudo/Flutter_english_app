import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import couponRoutes from './routes/coupon.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const mongoUri =
  process.env.MONGO_URI || 'mongodb://localhost:27017/language_stories';

mongoose
  .connect(mongoUri, { serverSelectionTimeoutMS: 5000 })
  .then(() => console.log('✅ MongoDB connected'))
  .catch((err) => {
    console.log('⚠️ MongoDB unavailable:', err.message);
    console.log('   Coupon API still works; analytics needs a database.');
  });

app.use('/api/coupon', couponRoutes);
app.use('/api/analytics', analyticsRoutes);

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

