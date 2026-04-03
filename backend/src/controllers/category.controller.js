const prisma = require('../config/prisma');

// ===== GET ALL CATEGORIES =====
const getCategories = async (req, res) => {
  try {
    const categories = await prisma.category.findMany({
      where: { isActive: true },
      include: {
        _count: { select: { services: true } }
      },
      orderBy: { createdAt: 'asc' }
    });

    res.json({ categories });
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== GET SINGLE CATEGORY =====
const getCategory = async (req, res) => {
  try {
    const { id } = req.params;

    const category = await prisma.category.findUnique({
      where: { id: parseInt(id) },
      include: {
        services: {
          where: { isActive: true }
        }
      }
    });

    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    res.json({ category });
  } catch (error) {
    console.error('Get category error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== CREATE CATEGORY (Admin only) =====
const createCategory = async (req, res) => {
  try {
    const { name, icon, description } = req.body;

    // Check if category already exists
    const existing = await prisma.category.findUnique({ where: { name } });
    if (existing) {
      return res.status(400).json({ message: 'Category already exists' });
    }

    const category = await prisma.category.create({
      data: { name, icon, description }
    });

    res.status(201).json({
      message: 'Category created successfully!',
      category
    });
  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== UPDATE CATEGORY (Admin only) =====
const updateCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, icon, description, isActive } = req.body;

    const category = await prisma.category.update({
      where: { id: parseInt(id) },
      data: { name, icon, description, isActive }
    });

    res.json({
      message: 'Category updated successfully!',
      category
    });
  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE CATEGORY (Admin only) =====
const deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.category.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Category deleted successfully!' });
  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getCategories,
  getCategory,
  createCategory,
  updateCategory,
  deleteCategory
};