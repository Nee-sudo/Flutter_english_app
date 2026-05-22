import { createHandler, methodNotAllowed } from '../lib/http.js';
import { assertAdmin } from '../lib/adminAuth.js';
import { listAdminTenses } from '../../backend/src/controllers/admin.controller.js';

export default createHandler(async (req, res) => {
  if (!assertAdmin(req, res)) return;
  if (req.method !== 'GET') {
    methodNotAllowed(res);
    return;
  }
  await listAdminTenses(req, res);
});
