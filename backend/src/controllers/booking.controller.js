const prisma = require('../config/prisma');

// ===== CREATE BOOKING (Client) =====
const createBooking = async (req, res) => {
  try {
    const { providerId, serviceId, addressId, scheduledAt, notes } = req.body;
    const userId = req.user.id;

    // Check provider exists and is verified
    const provider = await prisma.provider.findUnique({
      where: { id: parseInt(providerId) }
    });
    if (!provider) {
      return res.status(404).json({ message: 'Provider not found' });
    }
    if (!provider.isVerified) {
      return res.status(400).json({ message: 'Provider is not verified' });
    }

    // Check service exists
    const service = await prisma.service.findUnique({
      where: { id: parseInt(serviceId) }
    });
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Check provider offers this service
    const providerService = await prisma.providerService.findFirst({
      where: {
        providerId: parseInt(providerId),
        serviceId: parseInt(serviceId)
      }
    });

    const totalPrice = providerService ? providerService.price : service.basePrice;

    // Create booking
    const booking = await prisma.booking.create({
      data: {
        userId,
        providerId: parseInt(providerId),
        serviceId: parseInt(serviceId),
        addressId: parseInt(addressId),
        scheduledAt: new Date(scheduledAt),
        notes,
        totalPrice,
        status: 'PENDING'
      },
      include: {
        user: {
          select: { id: true, fullName: true, email: true, phone: true }
        },
        provider: {
          select: { id: true, fullName: true, phone: true }
        },
        service: {
          select: { id: true, name: true }
        },
        address: true
      }
    });

    // Create notification for provider
    await prisma.notification.create({
      data: {
        title: 'New Booking!',
        body: `You have a new booking for ${service.name}`,
        type: 'NEW_BOOKING',
        providerId: parseInt(providerId)
      }
    });

    res.status(201).json({
      message: 'Booking created successfully!',
      booking
    });

  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET USER BOOKINGS (Client) =====
const getUserBookings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    const bookings = await prisma.booking.findMany({
      where: {
        userId,
        ...(status && { status })
      },
      include: {
        provider: {
          select: { id: true, fullName: true, avatar: true, phone: true }
        },
        service: {
          select: { id: true, name: true, image: true }
        },
        address: true,
        payment: true,
        review: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ bookings });
  } catch (error) {
    console.error('Get user bookings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET SINGLE BOOKING =====
const getBooking = async (req, res) => {
  try {
    const { id } = req.params;

    const booking = await prisma.booking.findUnique({
      where: { id: parseInt(id) },
      include: {
        user: {
          select: { id: true, fullName: true, email: true, phone: true }
        },
        provider: {
          select: { id: true, fullName: true, avatar: true, phone: true }
        },
        service: {
          select: { id: true, name: true, image: true }
        },
        address: true,
        payment: true,
        review: true
      }
    });

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    res.json({ booking });
  } catch (error) {
    console.error('Get booking error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== UPDATE BOOKING STATUS =====
const updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['PENDING', 'CONFIRMED', 'ONGOING', 'COMPLETED', 'CANCELLED'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const booking = await prisma.booking.update({
      where: { id: parseInt(id) },
      data: { status },
      include: {
        user: {
          select: { id: true, fullName: true }
        },
        service: {
          select: { id: true, name: true }
        }
      }
    });

    // Notify user about status change
    await prisma.notification.create({
      data: {
        title: 'Booking Update',
        body: `Your booking for ${booking.service.name} is now ${status}`,
        type: 'BOOKING_UPDATE',
        userId: booking.userId
      }
    });

    res.json({
      message: 'Booking status updated!',
      booking
    });
  } catch (error) {
    console.error('Update booking status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== CANCEL BOOKING (Client) =====
const cancelBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await prisma.booking.findUnique({
      where: { id: parseInt(id) }
    });

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    if (booking.userId !== userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    if (['COMPLETED', 'CANCELLED'].includes(booking.status)) {
      return res.status(400).json({ message: 'Cannot cancel this booking' });
    }

    const updated = await prisma.booking.update({
      where: { id: parseInt(id) },
      data: { status: 'CANCELLED' }
    });

    res.json({
      message: 'Booking cancelled successfully!',
      booking: updated
    });
  } catch (error) {
    console.error('Cancel booking error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET ALL BOOKINGS (Admin) =====
const getAllBookings = async (req, res) => {
  try {
    const { status } = req.query;

    const bookings = await prisma.booking.findMany({
      where: {
        ...(status && { status })
      },
      include: {
        user: {
          select: { id: true, fullName: true, phone: true }
        },
        provider: {
          select: { id: true, fullName: true, phone: true }
        },
        service: {
          select: { id: true, name: true }
        },
        address: true,
        payment: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ bookings });
  } catch (error) {
    console.error('Get all bookings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createBooking,
  getUserBookings,
  getBooking,
  updateBookingStatus,
  cancelBooking,
  getAllBookings
};