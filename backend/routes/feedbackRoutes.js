const express = require('express');
const { create, listAll } = require('../controllers/feedbackController');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.post('/', requireAuth, create);
router.get('/', requireAuth, requireAdmin, listAll);

module.exports = router;
