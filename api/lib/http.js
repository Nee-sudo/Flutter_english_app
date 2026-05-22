import { applyCors, handlePreflight } from './cors.js';
import { connectDB, isDbReady } from './connect.js';
import { seedIfEmpty } from '../../backend/src/seed/seedDatabase.js';

function enhanceRes(res) {
  res.status = function status(code) {
    this.statusCode = code;
    return this;
  };
  res.json = function json(data) {
    if (!this.statusCode) this.statusCode = 200;
    this.setHeader('Content-Type', 'application/json');
    this.end(JSON.stringify(data));
  };
  return res;
}

async function parseBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  if (req.method !== 'POST' && req.method !== 'PUT' && req.method !== 'PATCH') {
    return {};
  }

  const chunks = [];
  for await (const chunk of req) {
    chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
  }

  const raw = Buffer.concat(chunks).toString('utf8');
  if (!raw) return {};

  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

export function createHandler(handler, { requireDb = true } = {}) {
  return async (req, res) => {
    enhanceRes(res);

    if (handlePreflight(req, res)) return;
    applyCors(req, res);

    try {
      req.body = await parseBody(req);
      req.query = req.query ?? {};

      if (requireDb) {
        await connectDB();
        if (isDbReady()) {
          await seedIfEmpty();
        }
      }

      await handler(req, res);
    } catch (err) {
      console.error('API error:', err);
      if (!res.writableEnded) {
        res.status(500).json({
          success: false,
          message: err.message || 'Internal server error',
        });
      }
    }
  };
}

export function methodNotAllowed(res) {
  res.status(405).json({ success: false, message: 'Method not allowed' });
}
