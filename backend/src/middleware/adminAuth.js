export const requireAdmin = (req, res, next) => {
  const configuredKey = process.env.ADMIN_API_KEY;

  if (!configuredKey) {
    return res.status(503).json({
      success: false,
      message: 'Admin API is disabled. Set ADMIN_API_KEY on the server.',
    });
  }

  const headerKey = req.headers['x-admin-key'];
  const bearer = req.headers.authorization?.startsWith('Bearer ')
    ? req.headers.authorization.slice(7)
    : null;
  const provided = headerKey || bearer;

  if (!provided || provided !== configuredKey) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized. Provide a valid X-Admin-Key or Authorization: Bearer token.',
    });
  }

  next();
};
