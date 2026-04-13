const mongoose = require('mongoose');

const schemeSchema = new mongoose.Schema(
  {
    scheme_name: { type: String, required: true, trim: true },
    scheme_type: {
      type: String,
      enum: ['Central', 'State'],
      required: true,
    },
    state: { type: String, default: '' },
    description: { type: String, default: '' },
    benefits: [{ type: String }],
    application_link: { type: String, default: '' },
    last_date: { type: String, default: '' },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
  },
  { timestamps: true }
);

schemeSchema.set('toJSON', {
  transform: (_, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    ret.basic_info = ret.description;
    if (ret.createdBy) {
      ret.createdBy = ret.createdBy.toString();
    }
    return ret;
  },
});

module.exports = mongoose.model('Scheme', schemeSchema);
