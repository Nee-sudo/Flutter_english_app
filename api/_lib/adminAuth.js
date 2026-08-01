export function assertAdmin(req, res) {
  const configuredKey = process.env.ADMIN_API_KEY;

  if (!configuredKey) {
    res.status(503).json({
      success: false,
      message: 'Admin API is disabled. Set ADMIN_API_KEY in Vercel environment variables.',
    });
    return false;
  }

  const headerKey = req.headers['x-admin-key'];
  const bearer = req.headers.authorization?.startsWith('Bearer ')
    ? req.headers.authorization.slice(7)
    : null;
  const provided = headerKey || bearer;

  if (!provided || provided !== configuredKey) {
    res.status(401).json({
      success: false,
      message:
        'Unauthorized. Provide a valid X-Admin-Key or Authorization: Bearer token.',
    });
    return false;
  }

  return true;
}
