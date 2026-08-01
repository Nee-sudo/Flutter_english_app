import { createHandler, methodNotAllowed } from '../_lib/http.js';
import { assertAdmin } from '../_lib/adminAuth.js';
import {
  listAdminStories,
  createStory,
} from '../../backend/src/controllers/admin.controller.js';

export default createHandler(async (req, res) => {
  if (!assertAdmin(req, res)) return;

  if (req.method === 'GET') {
    await listAdminStories(req, res);
    return;
  }

  if (req.method === 'POST') {
    await createStory(req, res);
    return;
  }

  methodNotAllowed(res);
});
