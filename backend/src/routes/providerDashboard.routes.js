const express = require('express');
const router = express.Router();
const {
  getProviderStats,
  getProviderBookings,
  updateBookingStatus,
  getProviderProfile,
  getProviderNotifications,
  markNotificationRead,
} = require('../controllers/providerDashboard.controller');
const { protectProvider } = require('../middleware/auth.middleware');

router.get('/stats', protectProvider, getProviderStats);
router.get('/bookings', protectProvider, getProviderBookings);
router.put('/bookings/:id/status', protectProvider, updateBookingStatus);
router.get('/profile', protectProvider, getProviderProfile);
router.get('/notifications', protectProvider, getProviderNotifications);
router.put('/notifications/:id/read', protectProvider, markNotificationRead);

module.exports = router;