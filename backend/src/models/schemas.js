import mongoose from 'mongoose';

export const TenseSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  description: String,
  emoji: String,
  createdAt: { type: Date, default: Date.now },
});

export const StorySchema = new mongoose.Schema({
  tenseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Tense', required: true },
  title: { type: String, required: true },
  englishText: { type: String, required: true },
  hindiText: { type: String, required: true },
  isDemo: { type: Boolean, default: false },
  category: String,
  createdAt: { type: Date, default: Date.now },
});

export const UserSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  couponAppliedAt: { type: Date, default: Date.now },
  ipAddress: String,
  userAgent: String,
  createdAt: { type: Date, default: Date.now },
});

export const AnalyticsSchema = new mongoose.Schema({
  totalUnlockedUsers: { type: Number, default: 0 },
  totalCouponAttempts: { type: Number, default: 0 },
  lastUpdated: { type: Date, default: Date.now },
});

export const PdfDownloadSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  language: { type: String, enum: ['english', 'hindi'], required: true },
  storyCount: { type: Number, required: true },
  downloadToken: { type: String, unique: true, required: true },
  ipAddress: String,
  userAgent: String,
  createdAt: { type: Date, default: Date.now },
});

export const Tense = mongoose.model('Tense', TenseSchema);
export const Story = mongoose.model('Story', StorySchema);
export const User = mongoose.model('User', UserSchema);
export const Analytics = mongoose.model('Analytics', AnalyticsSchema);
export const PdfDownload = mongoose.model('PdfDownload', PdfDownloadSchema);
