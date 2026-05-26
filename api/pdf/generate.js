import PDFDocument from 'pdfkit';
import { v4 as uuidv4 } from 'uuid';
import { Story } from '../../backend/src/models/schemas.js';
import { createHandler, methodNotAllowed } from '../lib/http.js';

function buildPdfBuffer(stories, language) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const buffers = [];

    doc.on('data', (chunk) => buffers.push(chunk));
    doc.on('error', reject);
    doc.on('end', () => resolve(Buffer.concat(buffers)));

    doc.fontSize(24).text('Language Stories', { align: 'center' });
    doc.fontSize(12).text(`Language: ${language.toUpperCase()}`, { align: 'center' });
    doc.moveDown(2);

    stories.forEach((story, index) => {
      doc.fontSize(14).text(`${index + 1}. ${story.title}`, { underline: true });
      doc.moveDown(0.5);
      const text = language === 'english' ? story.englishText : story.hindiText;
      doc.fontSize(11).text(text, { lineGap: 5 });
      doc.moveDown(1.5);
      if (index < stories.length - 1) doc.addPage();
    });

    doc.end();
  });
}

export default createHandler(async (req, res) => {
  if (req.method !== 'POST') {
    methodNotAllowed(res);
    return;
  }

  const { language, userId } = req.body ?? {};

  if (!['english', 'hindi'].includes(language)) {
    return res.status(400).json({
      success: false,
      error: 'Invalid language. Must be "english" or "hindi"',
    });
  }

  const stories = await Story.find().sort({ createdAt: 1 });

  if (stories.length === 0) {
    return res.status(404).json({ success: false, error: 'No stories found' });
  }

  const pdfBuffer = await buildPdfBuffer(stories, language);
  const downloadToken = uuidv4();
  const filename = `stories-${language}.pdf`;

  // Serverless-safe: return base64 in same response (no cross-instance cache)
  return res.status(200).json({
    success: true,
    message: `PDF ready with ${stories.length} stories`,
    downloadToken,
    filename,
    pdfBase64: pdfBuffer.toString('base64'),
    userId: userId ?? 'anonymous',
  });
});
