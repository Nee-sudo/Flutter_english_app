import { createHandler, methodNotAllowed } from './lib/http.js';

export default createHandler(
  async (req, res) => {
    if (req.method !== 'GET') {
      methodNotAllowed(res);
      return;
    }
    res.status(200).json({ status: 'OK', message: 'Server is running' });
  },
  { requireDb: false },
);
