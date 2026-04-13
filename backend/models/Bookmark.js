const mongoose = require('mongoose');

const bookmarkSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    schemeId: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

bookmarkSchema.index({ userId: 1, schemeId: 1 }, { unique: true });

bookmarkSchema.set('toJSON', {
  transform: (_, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Bookmark', bookmarkSchema);
