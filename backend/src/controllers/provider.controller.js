const bcrypt = require('bcryptjs');
const prisma = require('../config/prisma');
const { sendOTPEmail } = require('../utils/email');

// ===== GENERATE OTP =====
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// ===== REGISTER PROVIDER =====
const registerProvider = async (req, res) => {
  try {
    const { fullName, email, phone, password, bio } = req.body;

    const existingEmail = await prisma.provider.findUnique({ where: { email } });
    if (existingEmail) {
      return res.status(400).json({ message: 'Email already in use' });
    }

    const existingPhone = await prisma.provider.findUnique({ where: { phone } });
    if (existingPhone) {
      return res.status(400).json({ message: 'Phone number already in use' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    const provider = await prisma.provider.create({
      data: {
        fullName,
        email,
        phone,
        password: hashedPassword,
        bio,
        isVerified: false,
        isActive: true,
      }
    });

    res.status(201).json({
      message: 'Provider created successfully!',
      providerId: provider.id
    });

  } catch (error) {
    console.error('Register provider error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET ALL PROVIDERS (Admin) =====
const getProviders = async (req, res) => {
  try {
    const { isVerified, isActive } = req.query;

    const providers = await prisma.provider.findMany({
      where: {
        ...(isVerified !== undefined && { isVerified: isVerified === 'true' }),
        ...(isActive !== undefined && { isActive: isActive === 'true' }),
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        bio: true,
        isActive: true,
        isVerified: true,
        rating: true,
        totalReviews: true,
        createdAt: true,
        _count: { select: { bookings: true } }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ providers });
  } catch (error) {
    console.error('Get providers error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET SINGLE PROVIDER =====
const getProvider = async (req, res) => {
  try {
    const { id } = req.params;

    const provider = await prisma.provider.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        bio: true,
        isActive: true,
        isVerified: true,
        rating: true,
        totalReviews: true,
        createdAt: true,
        services: {
          include: { service: true }
        },
        reviews: {
          include: {
            user: {
              select: { fullName: true, avatar: true }
            }
          },
          orderBy: { createdAt: 'desc' },
          take: 10
        },
        _count: {
          select: { bookings: true, reviews: true }
        }
      }
    });

    if (!provider) {
      return res.status(404).json({ message: 'Provider not found' });
    }

    res.json({ provider });
  } catch (error) {
    console.error('Get provider error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== VERIFY PROVIDER (Admin only) =====
const verifyProvider = async (req, res) => {
  try {
    const { id } = req.params;

    const provider = await prisma.provider.update({
      where: { id: parseInt(id) },
      data: { isVerified: true },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        bio: true,
        isActive: true,
        isVerified: true,
        rating: true,
        totalReviews: true,
        createdAt: true,
      }
    });

    res.json({
      message: 'Provider verified successfully!',
      provider
    });
  } catch (error) {
    console.error('Verify provider error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== TOGGLE PROVIDER ACTIVE STATUS (Admin only) =====
const toggleProviderStatus = async (req, res) => {
  try {
    const { id } = req.params;

    const provider = await prisma.provider.findUnique({
      where: { id: parseInt(id) }
    });

    if (!provider) {
      return res.status(404).json({ message: 'Provider not found' });
    }

    const updated = await prisma.provider.update({
      where: { id: parseInt(id) },
      data: { isActive: !provider.isActive }
    });

    res.json({
      message: `Provider ${updated.isActive ? 'activated' : 'deactivated'} successfully!`,
      provider: updated
    });
  } catch (error) {
    console.error('Toggle provider status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE PROVIDER (Admin only) =====
const deleteProvider = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.provider.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Provider deleted successfully!' });
  } catch (error) {
    console.error('Delete provider error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== ADD SERVICE TO PROVIDER =====
const addProviderService = async (req, res) => {
  try {
    const { id } = req.params;
    const { serviceId, price } = req.body;

    const existing = await prisma.providerService.findFirst({
      where: {
        providerId: parseInt(id),
        serviceId: parseInt(serviceId)
      }
    });

    if (existing) {
      return res.status(400).json({ message: 'Service already added to this provider' });
    }

    const providerService = await prisma.providerService.create({
      data: {
        providerId: parseInt(id),
        serviceId: parseInt(serviceId),
        price: parseFloat(price)
      },
      include: { service: true }
    });

    res.status(201).json({
      message: 'Service added to provider successfully!',
      providerService
    });
  } catch (error) {
    console.error('Add provider service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  registerProvider,
  getProviders,
  getProvider,
  verifyProvider,
  toggleProviderStatus,
  deleteProvider,
  addProviderService
};