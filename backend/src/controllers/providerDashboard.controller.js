const prisma = require('../config/prisma');

// ===== GET PROVIDER DASHBOARD STATS =====
const getProviderStats = async (req, res) => {
  try {
    const providerId = req.provider.id;

    const [
      totalBookings,
      pendingBookings,
      confirmedBookings,
      completedBookings,
      cancelledBookings,
      recentBookings,
      totalEarnings,
      reviews,
    ] = await Promise.all([
      prisma.booking.count({ where: { providerId } }),
      prisma.booking.count({ where: { providerId, status: 'PENDING' } }),
      prisma.booking.count({ where: { providerId, status: 'CONFIRMED' } }),
      prisma.booking.count({ where: { providerId, status: 'COMPLETED' } }),
      prisma.booking.count({ where: { providerId, status: 'CANCELLED' } }),
      prisma.booking.findMany({
        where: { providerId },
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, fullName: true, phone: true, avatar: true } },
          service: { select: { id: true, name: true } },
          address: true,
        }
      }),
      prisma.booking.aggregate({
        where: { providerId, status: 'COMPLETED' },
        _sum: { totalPrice: true }
      }),
      prisma.review.findMany({
        where: { providerId },
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { fullName: true, avatar: true } }
        }
      }),
    ]);

    res.json({
      stats: {
        totalBookings,
        pendingBookings,
        confirmedBookings,
        completedBookings,
        cancelledBookings,
        totalEarnings: totalEarnings._sum.totalPrice || 0,
      },
      recentBookings,
      reviews,
    });
  } catch (error) {
    console.error('Provider stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET PROVIDER BOOKINGS =====
const getProviderBookings = async (req, res) => {
  try {
    const providerId = req.provider.id;
    const { status } = req.query;

    const bookings = await prisma.booking.findMany({
      where: {
        providerId,
        ...(status && { status })
      },
      include: {
        user: { select: { id: true, fullName: true, phone: true, avatar: true } },
        service: { select: { id: true, name: true } },
        address: true,
        review: true,
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ bookings });
  } catch (error) {
    console.error('Get provider bookings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== UPDATE BOOKING STATUS (Provider) =====
const updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const providerId = req.provider.id;

    const booking = await prisma.booking.findUnique({ where: { id: parseInt(id) } });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.providerId !== providerId) return res.status(403).json({ message: 'Not authorized' });

    const updated = await prisma.booking.update({
      where: { id: parseInt(id) },
      data: { status },
      include: {
        user: { select: { id: true, fullName: true } },
        service: { select: { name: true } }
      }
    });

    await prisma.notification.create({
      data: {
        title: 'Booking Update',
        body: `Your booking for ${updated.service.name} is now ${status}`,
        type: 'BOOKING_UPDATE',
        userId: updated.userId
      }
    });

    res.json({ message: 'Status updated!', booking: updated });
  } catch (error) {
    console.error('Update booking status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET PROVIDER PROFILE =====
const getProviderProfile = async (req, res) => {
  try {
    const providerId = req.provider.id;
    const provider = await prisma.provider.findUnique({
      where: { id: providerId },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        bio: true,
        isVerified: true,
        rating: true,
        totalReviews: true,
        createdAt: true,
        services: {
          include: { service: true }
        },
        _count: {
          select: { bookings: true, reviews: true }
        }
      }
    });
    res.json({ provider });
  } catch (error) {
    console.error('Get provider profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET PROVIDER NOTIFICATIONS =====
const getProviderNotifications = async (req, res) => {
  try {
    const providerId = req.provider.id;
    const notifications = await prisma.notification.findMany({
      where: { providerId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
    res.json({ notifications });
  } catch (error) {
    console.error('Get provider notifications error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== MARK NOTIFICATION AS READ =====
const markNotificationRead = async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.notification.update({
      where: { id: parseInt(id) },
      data: { isRead: true }
    });
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark notification error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getProviderStats,
  getProviderBookings,
  updateBookingStatus,
  getProviderProfile,
  getProviderNotifications,
  markNotificationRead,
};