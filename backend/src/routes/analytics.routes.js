import express from 'express';
import { trackUser, getAnalytics } from '../controllers/analytics.controller.js';

const router = express.Router();

router.post('/track', trackUser);
router.get('/stats', getAnalytics);

export default router;

