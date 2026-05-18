import mongoose from 'mongoose';
import { Tense, Story } from '../models/schemas.js';
import { serializeStory, serializeTense } from '../utils/storySerializer.js';

export const listTenses = async (req, res) => {
  try {
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database unavailable',
      });
    }

    const tenses = await Tense.find().sort({ createdAt: 1 });
    return res.status(200).json({
      success: true,
      data: tenses.map(serializeTense),
    });
  } catch (err) {
    console.error('listTenses:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to load tenses',
    });
  }
};

export const listStoriesByTense = async (req, res) => {
  const { tenseId } = req.query;

  if (!tenseId) {
    return res.status(400).json({
      success: false,
      message: 'Query parameter tenseId is required',
    });
  }

  if (!mongoose.Types.ObjectId.isValid(tenseId)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid tenseId',
    });
  }

  try {
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database unavailable',
      });
    }

    const stories = await Story.find({ tenseId }).sort({ isDemo: -1, createdAt: 1 });
    return res.status(200).json({
      success: true,
      data: stories.map(serializeStory),
    });
  } catch (err) {
    console.error('listStoriesByTense:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to load stories',
    });
  }
};
