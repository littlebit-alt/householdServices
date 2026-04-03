const express = require('express');
const router = express.Router();
const {
  createBooking,
  getUserBookings,
  getBooking,
  updateBookingStatus,
  cancelBooking,
  getAllBookings
} = require('../controllers/booking.controller');
const { protectUser, protectAdmin } = require('../middleware/auth.middleware');

router.post('/', protectUser, createBooking);
router.get('/my', protectUser, getUserBookings);
router.get('/all', protectAdmin, getAllBookings);
router.get('/:id', protectUser, getBooking);
router.put('/:id/status', protectAdmin, updateBookingStatus);
router.put('/:id/cancel', protectUser, cancelBooking);

module.exports = router;