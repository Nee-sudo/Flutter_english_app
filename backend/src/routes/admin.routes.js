import express from 'express';
import { requireAdmin } from '../middleware/adminAuth.js';
import {
  listAdminStories,
  createStory,
  updateStory,
  deleteStory,
  listAdminTenses,
} from '../controllers/admin.controller.js';

const router = express.Router();

router.use(requireAdmin);

router.get('/tenses', listAdminTenses);
router.get('/stories', listAdminStories);
router.post('/stories', createStory);
router.put('/stories/:id', updateStory);
router.delete('/stories/:id', deleteStory);

export default router;
