import { createHandler, methodNotAllowed } from './lib/http.js';
import { listStoriesByTense } from '../backend/src/controllers/content.controller.js';

export default createHandler(async (req, res) => {
  if (req.method !== 'GET') {
    methodNotAllowed(res);
    return;
  }
  await listStoriesByTense(req, res);
});
