export const verifyCoupon = (req, res) => {
  const { coupon } = req.body;

  if (!coupon) {
    return res.status(400).json({
      valid: false,
      message: 'Coupon code is required',
    });
  }

  const validCoupon = process.env.COUPON_CODE || 'NEER50';

  if (coupon.toUpperCase() === validCoupon) {
    return res.status(200).json({
      valid: true,
      message: 'Coupon code is valid. All stories unlocked!',
    });
  }

  return res.status(400).json({
    valid: false,
    message: 'Invalid coupon code. Please try again.',
  });
};

