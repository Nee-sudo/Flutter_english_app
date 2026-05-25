import PDFDocument from 'pdfkit';
import { v4 as uuidv4 } from 'uuid';
import { Story, PdfDownload } from '../models/schemas.js';

// Store generated PDFs in memory temporarily (in production, use cloud storage)
const pdfCache = new Map();

export const generatePdf = async (req, res) => {
  try {
    const { language } = req.body;
    const ipAddress = req.ip || req.connection.remoteAddress;
    const userAgent = req.get('user-agent');

    // Validate language
    if (!['english', 'hindi'].includes(language)) {
      return res.status(400).json({ error: 'Invalid language. Must be "english" or "hindi"' });
    }

    // Fetch all stories
    const stories = await Story.find();

    if (stories.length === 0) {
      return res.status(404).json({ error: 'No stories found' });
    }

    // Create PDF
    const doc = new PDFDocument({
      size: 'A4',
      margin: 50,
      bufferPages: true,
    });

    const buffers = [];
    doc.on('data', (buffer) => buffers.push(buffer));

    // Add title
    doc.fontSize(24).font('Helvetica-Bold').text('📖 Language Stories', { align: 'center' });
    doc.fontSize(12).font('Helvetica').text(`Language: ${language.toUpperCase()}`, { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(10).text(`Generated: ${new Date().toLocaleDateString()}`, { align: 'center' });
    doc.moveDown(2);

    // Add stories
    stories.forEach((story, index) => {
      doc.fontSize(14).font('Helvetica-Bold').text(`${index + 1}. ${story.title}`, { underline: true });
      doc.moveDown(0.5);

      const textContent = language === 'english' ? story.englishText : story.hindiText;
      doc.fontSize(11).font('Helvetica').text(textContent, {
        align: 'left',
        lineGap: 5,
      });

      doc.moveDown(1.5);

      // Add page break if needed (except after last story)
      if (index < stories.length - 1) {
        doc.addPage();
      }
    });

    // Finalize PDF
    doc.end();

    return new Promise((resolve) => {
      doc.on('finish', async () => {
        try {
          const pdfBuffer = Buffer.concat(buffers);
          const downloadToken = uuidv4();
          const userId = req.body.userId || `anonymous-${uuidv4()}`;

          // Store PDF in cache with TTL (expire after 24 hours)
          pdfCache.set(downloadToken, {
            buffer: pdfBuffer,
            language,
            storyCount: stories.length,
            createdAt: Date.now(),
            expiresAt: Date.now() + 24 * 60 * 60 * 1000,
          });

          // Track download in database
          await PdfDownload.create({
            userId,
            language,
            storyCount: stories.length,
            downloadToken,
            ipAddress,
            userAgent,
          });

          // Cleanup old entries from cache
          for (const [token, data] of pdfCache.entries()) {
            if (data.expiresAt < Date.now()) {
              pdfCache.delete(token);
            }
          }

          res.json({
            success: true,
            downloadToken,
            message: `PDF generated successfully with ${stories.length} stories in ${language}`,
          });

          resolve();
        } catch (error) {
          console.error('Error tracking PDF download:', error);
          res.status(500).json({ error: 'Failed to track download' });
          resolve();
        }
      });
    });
  } catch (error) {
    console.error('Error generating PDF:', error);
    res.status(500).json({ error: 'Failed to generate PDF', details: error.message });
  }
};

export const downloadPdf = (req, res) => {
  try {
    const { token } = req.params;

    const pdfData = pdfCache.get(token);

    if (!pdfData) {
      return res.status(404).json({ error: 'PDF not found or expired' });
    }

    // Check if expired
    if (pdfData.expiresAt < Date.now()) {
      pdfCache.delete(token);
      return res.status(404).json({ error: 'PDF has expired' });
    }

    // Send PDF
    res.contentType('application/pdf');
    res.header('Content-Disposition', `attachment; filename="stories-${pdfData.language}.pdf"`);
    res.send(pdfData.buffer);

    // Cleanup after download
    pdfCache.delete(token);
  } catch (error) {
    console.error('Error downloading PDF:', error);
    res.status(500).json({ error: 'Failed to download PDF' });
  }
};

export const getPdfStats = async (req, res) => {
  try {
    const stats = await PdfDownload.aggregate([
      {
        $group: {
          _id: '$language',
          count: { $sum: 1 },
          avgStoryCount: { $avg: '$storyCount' },
          latestDownload: { $max: '$createdAt' },
        },
      },
    ]);

    const totalDownloads = await PdfDownload.countDocuments();
    const recentDownloads = await PdfDownload.find()
      .sort({ createdAt: -1 })
      .limit(20)
      .select('language storyCount createdAt');

    res.json({
      totalDownloads,
      byLanguage: stats,
      recentDownloads,
    });
  } catch (error) {
    console.error('Error fetching PDF stats:', error);
    res.status(500).json({ error: 'Failed to fetch PDF statistics' });
  }
};
