import { createHandler, methodNotAllowed } from '../../lib/http.js';

// Token-based download is not reliable on serverless (no shared memory).
// Clients should use pdfBase64 from POST /api/pdf/generate instead.
export default createHandler(
  async (req, res) => {
    if (req.method !== 'GET') {
      methodNotAllowed(res);
      return;
    }

    return res.status(410).json({
      success: false,
      message:
        'Token download expired. Use POST /api/pdf/generate — the response includes pdfBase64 for direct download.',
    });
  },
  { requireDb: false },
);
