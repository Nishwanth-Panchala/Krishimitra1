const express = require('express');
const {
  listAll,
  create,
  listByType,
  listByState,
} = require('../controllers/schemeController');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.get('/', listAll);
router.get('/type/:type', listByType);
router.get('/state/:state', listByState);
router.post('/', requireAuth, requireAdmin, create);

module.exports = router;
