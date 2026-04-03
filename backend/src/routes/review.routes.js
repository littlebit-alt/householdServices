const express = require('express');
const router = express.Router();
const {
  createReview,
  getProviderReviews,
  getAllReviews,
  deleteReview
} = require('../controllers/review.controller');
const { protectUser, protectAdmin } = require('../middleware/auth.middleware');

router.post('/', protectUser, createReview);
router.get('/provider/:providerId', getProviderReviews);
router.get('/all', protectAdmin, getAllReviews);
router.delete('/:id', protectAdmin, deleteReview);

module.exports = router;