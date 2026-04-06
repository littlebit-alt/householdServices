const jwt = require('jsonwebtoken');
const prisma = require('../config/prisma');

// ===== PROTECT ADMIN ROUTES =====
const protectAdmin = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Not authorized, no token' });
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      console.error('JWT verification failed:', jwtError.message);
      return res.status(401).json({ message: 'Not authorized, invalid token' });
    }

    if (decoded.type !== 'admin') {
      return res.status(401).json({ message: 'Not authorized, admins only' });
    }

    // Get admin from database
    const admin = await prisma.admin.findUnique({
      where: { id: decoded.id },
      select: {
        id: true,
        fullName: true,
        email: true,
        role: true,
      }
    });

    if (!admin) {
      return res.status(401).json({ message: 'Admin not found' });
    }

    req.admin = admin;
    next();

  } catch (error) {
    console.error('Admin auth middleware error:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// ===== PROTECT USER ROUTES =====
const protectUser = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Not authorized, no token' });
    }

    const token = authHeader.split(' ')[1];

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      console.error('JWT verification failed:', jwtError.message);
      return res.status(401).json({ message: 'Not authorized, invalid token' });
    }

    if (decoded.type !== 'user') {
      return res.status(401).json({ message: 'Not authorized' });
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        isActive: true,
        isVerified: true,
      }
    });

    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    if (!user.isActive) {
      return res.status(401).json({ message: 'Account deactivated' });
    }

    req.user = user;
    next();

  } catch (error) {
    console.error('User auth middleware error:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// ===== PROTECT PROVIDER ROUTES =====
const protectProvider = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Not authorized, no token' });
    }

    const token = authHeader.split(' ')[1];

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      console.error('JWT verification failed:', jwtError.message);
      return res.status(401).json({ message: 'Not authorized, invalid token' });
    }

    if (decoded.type !== 'provider') {
      return res.status(401).json({ message: 'Not authorized' });
    }

    const provider = await prisma.provider.findUnique({
      where: { id: decoded.id },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        isActive: true,
        isVerified: true,
      }
    });

    if (!provider) {
      return res.status(401).json({ message: 'Provider not found' });
    }

    if (!provider.isActive) {
      return res.status(401).json({ message: 'Account deactivated' });
    }

    req.provider = provider;
    next();

  } catch (error) {
    console.error('Provider auth middleware error:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { protectUser, protectAdmin, protectProvider };