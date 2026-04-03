const express = require('express');
const router = express.Router();
const {
  getServices,
  getService,
  createService,
  updateService,
  deleteService
} = require('../controllers/service.controller');
const { protectAdmin } = require('../middleware/auth.middleware');

router.get('/', getServices);
router.get('/:id', getService);
router.post('/', protectAdmin, createService);
router.put('/:id', protectAdmin, updateService);
router.delete('/:id', protectAdmin, deleteService);

module.exports = router;