const isProduction = process.env.NODE_ENV === 'production';
const configuredOrigins = process.env.FRONTEND_URL
  ? process.env.FRONTEND_URL.split(',').map((o) => o.trim()).filter(Boolean)
  : [];

const localhostOrigin = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

function isAllowedOrigin(origin) {
  if (!origin) return true;
  if (configuredOrigins.includes(origin)) return true;
  if (!isProduction && localhostOrigin.test(origin)) return true;
  // Same Vercel deployment (preview/production)
  if (origin.endsWith('.vercel.app')) return true;
  return false;
}

export function applyCors(req, res) {
  const origin = req.headers.origin;

  if (origin && isAllowedOrigin(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  } else if (!origin) {
    res.setHeader('Access-Control-Allow-Origin', '*');
  }

  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, DELETE, OPTIONS',
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, X-Admin-Key',
  );
}

export function handlePreflight(req, res) {
  if (req.method === 'OPTIONS') {
    applyCors(req, res);
    res.statusCode = 204;
    res.end();
    return true;
  }
  return false;
}
