const Bookmark = require('../models/Bookmark');

async function toggle(req, res) {
  try {
    const { schemeId } = req.body;
    if (!schemeId || !String(schemeId).trim()) {
      return res.status(400).json({ message: 'schemeId is required' });
    }
    const sid = String(schemeId).trim();
    const userId = req.user.sub;

    const existing = await Bookmark.findOne({ userId, schemeId: sid });
    if (existing) {
      await existing.deleteOne();
      return res.json({ schemeId: sid, bookmarked: false });
    }

    await Bookmark.create({ userId, schemeId: sid });
    return res.json({ schemeId: sid, bookmarked: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Bookmark update failed' });
  }
}

async function listByUser(req, res) {
  try {
    const { userId } = req.params;
    if (!userId) {
      return res.status(400).json({ message: 'userId is required' });
    }

    if (req.user.sub !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const rows = await Bookmark.find({ userId }).lean();
    const schemeIds = rows.map((r) => r.schemeId);
    return res.json({ schemeIds });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load bookmarks' });
  }
}

module.exports = { toggle, listByUser };
