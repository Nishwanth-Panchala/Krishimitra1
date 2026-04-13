const Feedback = require('../models/Feedback');

async function create(req, res) {
  try {
    const { message } = req.body;
    if (!message || !String(message).trim()) {
      return res.status(400).json({ message: 'message is required' });
    }

    const entry = await Feedback.create({
      userId: req.user.sub,
      message: String(message).trim(),
    });

    return res.status(201).json({
      id: entry._id.toString(),
      userId: entry.userId.toString(),
      message: entry.message,
      createdAt: entry.createdAt,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to submit feedback' });
  }
}

async function listAll(req, res) {
  try {
    const items = await Feedback.find()
      .sort({ createdAt: -1 })
      .populate('userId', 'mobile name')
      .lean();

    const mapped = items.map((f) => {
      const u = f.userId;
      const mobile =
        u && typeof u === 'object' && u.mobile ? u.mobile : 'unknown';
      return {
        id: f._id.toString(),
        mobileNumber: mobile,
        message: f.message,
        createdAt: f.createdAt,
      };
    });

    return res.json(mapped);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load feedback' });
  }
}

module.exports = { create, listAll };
