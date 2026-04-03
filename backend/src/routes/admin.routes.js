const express = require('express');
const router = express.Router();

const {
  getDashboardStats,
  getUsers,
  toggleUserStatus,
  deleteUser, changePassword 
} = require('../controllers/admin.controller');
const { protectAdmin } = require('../middleware/auth.middleware');

router.get('/dashboard', protectAdmin, getDashboardStats);
router.get('/users', protectAdmin, getUsers);
router.put('/users/:id/toggle-status', protectAdmin, toggleUserStatus);
router.delete('/users/:id', protectAdmin, deleteUser);
router.put('/change-password', protectAdmin, changePassword);

module.exports = router;