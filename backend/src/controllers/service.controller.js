const prisma = require('../config/prisma');

// ===== GET ALL SERVICES =====
const getServices = async (req, res) => {
  try {
    const { categoryId } = req.query;

    const services = await prisma.service.findMany({
      where: {
        isActive: true,
        ...(categoryId && { categoryId: parseInt(categoryId) })
      },
      include: {
        category: true,
        _count: { select: { providers: true } }
      },
      orderBy: { createdAt: 'asc' }
    });

    res.json({ services });
  } catch (error) {
    console.error('Get services error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET SINGLE SERVICE =====
const getService = async (req, res) => {
  try {
    const { id } = req.params;

    const service = await prisma.service.findUnique({
      where: { id: parseInt(id) },
      include: {
        category: true,
        providers: {
          include: {
            provider: {
              select: {
                id: true,
                fullName: true,
                avatar: true,
                rating: true,
                totalReviews: true,
              }
            }
          }
        }
      }
    });

    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    res.json({ service });
  } catch (error) {
    console.error('Get service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== CREATE SERVICE (Admin only) =====
const createService = async (req, res) => {
  try {
    const { name, description, basePrice, categoryId, image } = req.body;

    // Check category exists
    const category = await prisma.category.findUnique({
      where: { id: parseInt(categoryId) }
    });
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    const service = await prisma.service.create({
      data: {
        name,
        description,
        basePrice: parseFloat(basePrice),
        categoryId: parseInt(categoryId),
        image
      },
      include: { category: true }
    });

    res.status(201).json({
      message: 'Service created successfully!',
      service
    });
  } catch (error) {
    console.error('Create service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== UPDATE SERVICE (Admin only) =====
const updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, basePrice, categoryId, image, isActive } = req.body;

    const service = await prisma.service.update({
      where: { id: parseInt(id) },
      data: {
        name,
        description,
        ...(basePrice && { basePrice: parseFloat(basePrice) }),
        ...(categoryId && { categoryId: parseInt(categoryId) }),
        image,
        isActive
      },
      include: { category: true }
    });

    res.json({
      message: 'Service updated successfully!',
      service
    });
  } catch (error) {
    console.error('Update service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE SERVICE (Admin only) =====
const deleteService = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.service.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Service deleted successfully!' });
  } catch (error) {
    console.error('Delete service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getServices,
  getService,
  createService,
  updateService,
  deleteService
};