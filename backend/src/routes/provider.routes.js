const express = require('express');
const router = express.Router();
const {
  registerProvider,
  getProviders,
  getProvider,
  verifyProvider,
  toggleProviderStatus,
  deleteProvider,
  providerLogin,
  verifyProviderOTP,
  addProviderService,
  
} = require('../controllers/provider.controller');
const { protectAdmin } = require('../middleware/auth.middleware');

router.post('/register', registerProvider);
router.post('/verify-otp', verifyProviderOTP);
router.post('/login', providerLogin);
router.get('/', getProviders);
router.get('/:id', getProvider);
router.put('/:id/verify', protectAdmin, verifyProvider);
router.put('/:id/toggle-status', protectAdmin, toggleProviderStatus);
router.delete('/:id', protectAdmin, deleteProvider);
router.post('/:id/services', protectAdmin, addProviderService);

module.exports = router;