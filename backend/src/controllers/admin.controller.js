const prisma = require('../config/prisma');
const bcrypt = require('bcryptjs');

// ===== GET DASHBOARD STATS =====
const getDashboardStats = async (req, res) => {
  try {
    // Run all queries at the same time for speed
    const [
      totalUsers,
      totalProviders,
      totalBookings,
      pendingBookings,
      completedBookings,
      cancelledBookings,
      totalServices,
      totalCategories,
      recentBookings,
      recentUsers,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.provider.count(),
      prisma.booking.count(),
      prisma.booking.count({ where: { status: 'PENDING' } }),
      prisma.booking.count({ where: { status: 'COMPLETED' } }),
      prisma.booking.count({ where: { status: 'CANCELLED' } }),
      prisma.service.count(),
      prisma.category.count(),
      prisma.booking.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { fullName: true } },
          provider: { select: { fullName: true } },
          service: { select: { name: true } }
        }
      }),
      prisma.user.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          fullName: true,
          email: true,
          createdAt: true
        }
      }),
    ]);

    // Calculate total revenue
    const revenueResult = await prisma.booking.aggregate({
      where: { status: 'COMPLETED' },
      _sum: { totalPrice: true }
    });

    const totalRevenue = revenueResult._sum.totalPrice || 0;

    res.json({
      stats: {
        totalUsers,
        totalProviders,
        totalBookings,
        pendingBookings,
        completedBookings,
        cancelledBookings,
        totalServices,
        totalCategories,
        totalRevenue,
      },
      recentBookings,
      recentUsers,
    });

  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET ALL USERS (Admin) =====
const getUsers = async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        isActive: true,
        isVerified: true,
        createdAt: true,
        _count: { select: { bookings: true } }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ users });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== TOGGLE USER STATUS (Admin) =====
const toggleUserStatus = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({
      where: { id: parseInt(id) }
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const updated = await prisma.user.update({
      where: { id: parseInt(id) },
      data: { isActive: !user.isActive }
    });

    res.json({
      message: `User ${updated.isActive ? 'activated' : 'deactivated'} successfully!`,
      user: updated
    });
  } catch (error) {
    console.error('Toggle user status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE USER (Admin) =====
const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.user.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'User deleted successfully!' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
// ===== CHANGE ADMIN PASSWORD =====
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const adminId = req.admin.id;

    const admin = await prisma.admin.findUnique({
      where: { id: adminId }
    });

    const isMatch = await bcrypt.compare(currentPassword, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    const hashed = await bcrypt.hash(newPassword, 12);
    await prisma.admin.update({
      where: { id: adminId },
      data: { password: hashed }
    });

    res.json({ message: 'Password changed successfully!' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getDashboardStats,
  getUsers,
  toggleUserStatus,
  deleteUser,
  changePassword
};