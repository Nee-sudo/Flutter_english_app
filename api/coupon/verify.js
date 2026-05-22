import { createHandler, methodNotAllowed } from '../lib/http.js';
import { verifyCoupon } from '../../backend/src/controllers/coupon.controller.js';

export default createHandler(
  async (req, res) => {
    if (req.method !== 'POST') {
      methodNotAllowed(res);
      return;
    }
    await verifyCoupon(req, res);
  },
  { requireDb: false },
);
