import mongoose from 'mongoose';
import { Tense, Story } from '../models/schemas.js';
import { serializeStory, serializeTense } from '../utils/storySerializer.js';

function validateStoryBody(body, { requireTenseId = false } = {}) {
  const errors = [];
  const { tenseId, title, englishText, hindiText } = body;

  if (requireTenseId && !tenseId) errors.push('tenseId is required');
  if (requireTenseId && tenseId && !mongoose.Types.ObjectId.isValid(tenseId)) {
    errors.push('tenseId must be a valid MongoDB id');
  }
  if (title !== undefined && !String(title).trim()) errors.push('title cannot be empty');
  if (englishText !== undefined && !String(englishText).trim()) {
    errors.push('englishText cannot be empty');
  }
  if (hindiText !== undefined && !String(hindiText).trim()) {
    errors.push('hindiText cannot be empty');
  }

  return errors;
}

export const listAdminStories = async (req, res) => {
  try {
    const filter = {};
    const { tenseId } = req.query;

    if (tenseId) {
      if (!mongoose.Types.ObjectId.isValid(tenseId)) {
        return res.status(400).json({ success: false, message: 'Invalid tenseId' });
      }
      filter.tenseId = tenseId;
    }

    const stories = await Story.find(filter)
      .populate('tenseId', 'name emoji')
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: stories.map((s) => ({
        ...serializeStory(s),
        tenseName: s.tenseId?.name ?? null,
      })),
    });
  } catch (err) {
    console.error('listAdminStories:', err);
    return res.status(500).json({ success: false, message: 'Failed to list stories' });
  }
};

export const createStory = async (req, res) => {
  const errors = validateStoryBody(req.body, { requireTenseId: true });
  if (errors.length) {
    return res.status(400).json({ success: false, message: errors.join('; ') });
  }

  const { tenseId, title, englishText, hindiText, isDemo = false, category } = req.body;

  try {
    const tense = await Tense.findById(tenseId);
    if (!tense) {
      return res.status(404).json({ success: false, message: 'Tense not found' });
    }

    const story = await Story.create({
      tenseId,
      title: String(title).trim(),
      englishText: String(englishText).trim(),
      hindiText: String(hindiText).trim(),
      isDemo: Boolean(isDemo),
      category: category ? String(category).trim() : undefined,
    });

    return res.status(201).json({
      success: true,
      message: 'Premium story created',
      data: serializeStory(story),
    });
  } catch (err) {
    console.error('createStory:', err);
    return res.status(500).json({ success: false, message: 'Failed to create story' });
  }
};

export const updateStory = async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false, message: 'Invalid story id' });
  }

  const errors = validateStoryBody(req.body);
  if (errors.length) {
    return res.status(400).json({ success: false, message: errors.join('; ') });
  }

  const { title, englishText, hindiText, isDemo, category, tenseId } = req.body;
  const updates = {};

  if (title !== undefined) updates.title = String(title).trim();
  if (englishText !== undefined) updates.englishText = String(englishText).trim();
  if (hindiText !== undefined) updates.hindiText = String(hindiText).trim();
  if (isDemo !== undefined) updates.isDemo = Boolean(isDemo);
  if (category !== undefined) updates.category = String(category).trim() || undefined;

  if (tenseId !== undefined) {
    if (!mongoose.Types.ObjectId.isValid(tenseId)) {
      return res.status(400).json({ success: false, message: 'Invalid tenseId' });
    }
    try {
      const tense = await Tense.findById(tenseId);
      if (!tense) {
        return res.status(404).json({ success: false, message: 'Tense not found' });
      }
      updates.tenseId = tenseId;
    } catch (err) {
      console.error('updateStory - tense lookup:', err);
      return res.status(500).json({ success: false, message: 'Failed to verify tense' });
    }
  }

  if (Object.keys(updates).length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Provide at least one field to update',
    });
  }

  try {
    const story = await Story.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true,
    });

    if (!story) {
      return res.status(404).json({ success: false, message: 'Story not found' });
    }

    return res.status(200).json({
      success: true,
      message: 'Story updated',
      data: serializeStory(story),
    });
  } catch (err) {
    console.error('updateStory:', err);
    return res.status(500).json({ success: false, message: 'Failed to update story' });
  }
};

export const deleteStory = async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false, message: 'Invalid story id' });
  }

  try {
    const story = await Story.findByIdAndDelete(id);
    if (!story) {
      return res.status(404).json({ success: false, message: 'Story not found' });
    }

    return res.status(200).json({
      success: true,
      message: 'Story deleted',
    });
  } catch (err) {
    console.error('deleteStory:', err);
    return res.status(500).json({ success: false, message: 'Failed to delete story' });
  }
};

export const listAdminTenses = async (req, res) => {
  try {
    const tenses = await Tense.find().sort({ createdAt: 1 });
    return res.status(200).json({
      success: true,
      data: tenses.map(serializeTense),
    });
  } catch (err) {
    console.error('listAdminTenses:', err);
    return res.status(500).json({ success: false, message: 'Failed to list tenses' });
  }
};
