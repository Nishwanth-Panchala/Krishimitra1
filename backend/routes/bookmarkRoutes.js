const express = require('express');
const { toggle, listByUser } = require('../controllers/bookmarkController');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/', requireAuth, toggle);
router.get('/:userId', requireAuth, listByUser);

module.exports = router;
