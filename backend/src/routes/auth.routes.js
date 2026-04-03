const express = require('express');
const router = express.Router();
const {
  register,
  verifyOTP,
  login,
  forgotPassword,
  resetPassword,
  adminLogin
} = require('../controllers/auth.controller');

router.post('/register', register);
router.post('/verify-otp', verifyOTP);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.post('/admin/login', adminLogin);

module.exports = router;