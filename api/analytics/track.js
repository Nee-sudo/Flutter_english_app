import { createHandler, methodNotAllowed } from '../lib/http.js';
import { trackUser } from '../../backend/src/controllers/analytics.controller.js';

export default createHandler(async (req, res) => {
  if (req.method !== 'POST') {
    methodNotAllowed(res);
    return;
  }
  await trackUser(req, res);
});
