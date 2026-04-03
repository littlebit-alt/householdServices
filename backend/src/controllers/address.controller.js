const prisma = require('../config/prisma');

// ===== GET USER ADDRESSES =====
const getAddresses = async (req, res) => {
  try {
    const userId = req.user.id;

    const addresses = await prisma.address.findMany({
      where: { userId },
      orderBy: { isDefault: 'desc' }
    });

    res.json({ addresses });
  } catch (error) {
    console.error('Get addresses error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== CREATE ADDRESS =====
const createAddress = async (req, res) => {
  try {
    const userId = req.user.id;
    const { label, address, city, lat, lng, isDefault } = req.body;

    // If this is default, remove default from others
    if (isDefault) {
      await prisma.address.updateMany({
        where: { userId },
        data: { isDefault: false }
      });
    }

    const newAddress = await prisma.address.create({
      data: {
        userId,
        label,
        address,
        city,
        lat: lat ? parseFloat(lat) : null,
        lng: lng ? parseFloat(lng) : null,
        isDefault: isDefault || false
      }
    });

    res.status(201).json({
      message: 'Address created successfully!',
      address: newAddress
    });
  } catch (error) {
    console.error('Create address error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== UPDATE ADDRESS =====
const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { label, address, city, lat, lng, isDefault } = req.body;

    if (isDefault) {
      await prisma.address.updateMany({
        where: { userId },
        data: { isDefault: false }
      });
    }

    const updated = await prisma.address.update({
      where: { id: parseInt(id) },
      data: {
        label,
        address,
        city,
        lat: lat ? parseFloat(lat) : null,
        lng: lng ? parseFloat(lng) : null,
        isDefault: isDefault || false
      }
    });

    res.json({
      message: 'Address updated successfully!',
      address: updated
    });
  } catch (error) {
    console.error('Update address error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ===== DELETE ADDRESS =====
const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.address.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Address deleted successfully!' });
  } catch (error) {
    console.error('Delete address error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getAddresses,
  createAddress,
  updateAddress,
  deleteAddress
};