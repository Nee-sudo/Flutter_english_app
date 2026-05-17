import { User, Analytics } from '../models/schemas.js';

export const trackUser = async (req, res) => {
  try {
    const { userId, ipAddress } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    const existingUser = await User.findOne({ userId });
    if (existingUser) {
      return res.status(200).json({
        success: true,
        message: 'User already tracked',
        totalUsers: await User.countDocuments(),
      });
    }

    const newUser = new User({
      userId,
      ipAddress,
      userAgent: req.headers['user-agent'],
    });

    await newUser.save();

    let analytics = await Analytics.findOne();
    if (!analytics) {
      analytics = new Analytics({ totalUnlockedUsers: 1 });
    } else {
      analytics.totalUnlockedUsers += 1;
      analytics.lastUpdated = new Date();
    }

    await analytics.save();

    return res.status(200).json({
      success: true,
      message: 'User tracked successfully',
      totalUsers: await User.countDocuments(),
    });
  } catch (error) {
    console.error('Track user error:', error);
    if (error.name === 'MongoServerError' || error.name === 'MongooseError') {
      return res.status(503).json({
        success: false,
        message: 'Analytics unavailable (database not connected)',
      });
    }
    return res.status(500).json({
      success: false,
      message: 'Error tracking user',
      error: error.message,
    });
  }
};

export const getAnalytics = async (req, res) => {
  try {
    const analytics = await Analytics.findOne();
    const totalUsers = await User.countDocuments();

    return res.status(200).json({
      success: true,
      data: {
        totalUnlockedUsers: analytics?.totalUnlockedUsers || 0,
        totalUsers,
        lastUpdated: analytics?.lastUpdated,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Error fetching analytics',
      error: error.message,
    });
  }
};

