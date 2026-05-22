import { createHandler, methodNotAllowed } from '../../lib/http.js';
import { assertAdmin } from '../../lib/adminAuth.js';
import {
  updateStory,
  deleteStory,
} from '../../../backend/src/controllers/admin.controller.js';

export default createHandler(async (req, res) => {
  if (!assertAdmin(req, res)) return;

  req.params = { id: req.query.id };

  if (req.method === 'PUT') {
    await updateStory(req, res);
    return;
  }

  if (req.method === 'DELETE') {
    await deleteStory(req, res);
    return;
  }

  methodNotAllowed(res);
});
