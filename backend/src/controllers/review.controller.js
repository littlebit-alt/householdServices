const prisma = require('../config/prisma');

// ===== CREATE REVIEW =====
const createReview = async (req, res) => {
  try {
    const userId = req.user.id;
    const { bookingId, rating, comment } = req.body;

    // Check booking exists and belongs to user
    const booking = await prisma.booking.findUnique({
      where: { id: parseInt(bookingId) }
    });

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    if (booking.userId !== userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    if (booking.status !== 'COMPLETED') {
      return res.status(400).json({ message: 'Can only review completed bookings' });
    }

    // Check if already reviewed
    const existing = await prisma.review.findUnique({
      where: { bookingId: parseInt(bookingId) }
    });
    if (existing) {
      return res.status(400).json({ message: 'Booking already reviewed' });
    }

    // Create review
    const review = await prisma.review.create({
      data: {
        userId,
        providerId: booking.providerId,
        bookingId: parseInt(bookingId),
        rating: parseInt(rating),
        comment
      }
    });

    // Update provider rating
    const reviews = await prisma.review.findMany({
      where: { providerId: booking.providerId }
    });

    const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;

    await prisma.provider.update({
      where: { id: booking.providerId },
      data: {
        rating: parseFloat(avgRating.toFixed(1)),
        totalReviews: reviews.length
      }
    });

    res.status(201).json({
      message: 'Review submitted successfully!',
      review
    });

  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET PROVIDER REVIEWS =====
const getProviderReviews = async (req, res) => {
  try {
    const { providerId } = req.params;

    const reviews = await prisma.review.findMany({
      where: { providerId: parseInt(providerId) },
      include: {
        user: {
          select: { id: true, fullName: true, avatar: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ reviews });
  } catch (error) {
    console.error('Get provider reviews error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET ALL REVIEWS (Admin) =====
const getAllReviews = async (req, res) => {
  try {
    const reviews = await prisma.review.findMany({
      include: {
        user: {
          select: { id: true, fullName: true }
        },
        provider: {
          select: { id: true, fullName: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ reviews });
  } catch (error) {
    console.error('Get all reviews error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE REVIEW (Admin) =====
const deleteReview = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.review.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Review deleted successfully!' });
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createReview,
  getProviderReviews,
  getAllReviews,
  deleteReview
};