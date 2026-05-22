import { createHandler, methodNotAllowed } from './lib/http.js';
import { listTenses } from '../backend/src/controllers/content.controller.js';

export default createHandler(async (req, res) => {
  if (req.method !== 'GET') {
    methodNotAllowed(res);
    return;
  }
  await listTenses(req, res);
});
