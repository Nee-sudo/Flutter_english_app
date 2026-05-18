import express from 'express';
import { listTenses, listStoriesByTense } from '../controllers/content.controller.js';

const router = express.Router();

router.get('/tenses', listTenses);
router.get('/stories', listStoriesByTense);

export default router;
