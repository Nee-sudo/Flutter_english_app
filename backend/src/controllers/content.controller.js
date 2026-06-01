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

    // 1. Fetch the data from MongoDB (Sorting by isDemo first)
    const stories = await Story.find({ tenseId }).sort({ isDemo: -1 });

    // 2. Extract and numerically sort the documents by the number in the title string
    stories.sort((a, b) => {
      // If one is a demo and the other isn't, keep the isDemo sorting priority intact
      if (a.isDemo !== b.isDemo) {
        return b.isDemo - a.isDemo; 
      }

      // Extract the numbers from the beginning of the title (e.g. "19. Title" -> 19)
      const numA = parseInt(a.title, 10) || 0;
      const numB = parseInt(b.title, 10) || 0;

      // Mathematically compare the values
      return numA - numB;
    });

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