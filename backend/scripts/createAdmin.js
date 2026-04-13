/**
 * One-time: create an admin user in MongoDB.
 * Usage (from backend/): node scripts/createAdmin.js <mobile> <password> [name]
 */
require('dotenv').config();
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../models/User');

async function main() {
  const [, , mobile, password, name = 'Admin'] = process.argv;
  if (!mobile || !password) {
    console.error('Usage: node scripts/createAdmin.js <mobile> <password> [name]');
    process.exit(1);
  }
  if (!process.env.MONGO_URI) {
    console.error('MONGO_URI missing in .env');
    process.exit(1);
  }

  await mongoose.connect(process.env.MONGO_URI);
  const hashed = await bcrypt.hash(password, 10);
  await User.findOneAndUpdate(
    { mobile: String(mobile).trim() },
    {
      $set: {
        name,
        mobile: String(mobile).trim(),
        password: hashed,
        role: 'admin',
        state: '',
        language: '',
        cropTypes: [],
        soilType: '',
        acres: 0,
      },
    },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
  console.log('Admin user ready:', mobile.trim());
  await mongoose.disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
