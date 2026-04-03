const express = require('express');
const router = express.Router();
const {
  getAddresses,
  createAddress,
  updateAddress,
  deleteAddress
} = require('../controllers/address.controller');
const { protectUser } = require('../middleware/auth.middleware');

router.get('/', protectUser, getAddresses);
router.post('/', protectUser, createAddress);
router.put('/:id', protectUser, updateAddress);
router.delete('/:id', protectUser, deleteAddress);

module.exports = router;