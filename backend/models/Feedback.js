const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    message: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

feedbackSchema.set('toJSON', {
  transform: (_, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    if (ret.userId && typeof ret.userId === 'object') {
      ret.userId = ret.userId._id
        ? ret.userId._id.toString()
        : ret.userId.toString();
    }
    return ret;
  },
});

module.exports = mongoose.model('Feedback', feedbackSchema);
