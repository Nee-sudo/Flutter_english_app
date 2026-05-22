import { createHandler, methodNotAllowed } from '../lib/http.js';

export default createHandler(
  async (req, res) => {
    if (req.method !== 'POST') {
      methodNotAllowed(res);
      return;
    }

    const { coupon } = req.body ?? {};

    if (!coupon) {
      return res.status(400).json({
        valid: false,
        message: 'Coupon code is required',
      });
    }

    const validCoupon = (process.env.COUPON_CODE || 'NEER50').toUpperCase();

    if (String(coupon).trim().toUpperCase() === validCoupon) {
      return res.status(200).json({
        valid: true,
        message: 'Coupon code is valid. All stories unlocked!',
      });
    }

    return res.status(400).json({
      valid: false,
      message: 'Invalid coupon code. Please try again.',
    });
  },
  { requireDb: false },
);
