import express from 'express';
import { generatePdf, downloadPdf, getPdfStats } from '../controllers/pdf.controller.js';

const router = express.Router();

// Generate PDF with selected language
router.post('/generate', generatePdf);

// Download PDF by token
router.get('/download/:token', downloadPdf);

// Get PDF download statistics (admin)
router.get('/stats', getPdfStats);

export default router;
