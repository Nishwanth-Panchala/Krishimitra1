const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

function signToken(user) {
  return jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
      mobile: user.mobile,
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

function userResponse(doc) {
  const json = doc.toJSON();
  return {
    id: json.id,
    name: json.name,
    mobile: json.mobile,
    state: json.state,
    language: json.language,
    cropTypes: json.cropTypes,
    soilType: json.soilType,
    acres: json.acres,
    role: json.role,
  };
}

async function register(req, res) {
  try {
    const {
      name,
      mobile,
      password,
      state,
      language,
      cropTypes,
      soilType,
      acres,
    } = req.body;

    if (!name || !mobile || !password) {
      return res.status(400).json({ message: 'name, mobile, and password are required' });
    }

    const existing = await User.findOne({ mobile: String(mobile).trim() });
    if (existing) {
      return res.status(409).json({ message: 'Mobile number already registered' });
    }

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({
      name: String(name).trim(),
      mobile: String(mobile).trim(),
      password: hashed,
      state: state ?? '',
      language: language ?? '',
      cropTypes: Array.isArray(cropTypes) ? cropTypes : [],
      soilType: soilType ?? '',
      acres: Number(acres) || 0,
      role: 'user',
    });

    const token = signToken(user);
    return res.status(201).json({
      token,
      user: userResponse(user),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Registration failed' });
  }
}

async function login(req, res) {
  try {
    const { mobile, password } = req.body;
    if (!mobile || !password) {
      return res.status(400).json({ message: 'mobile and password are required' });
    }

    const user = await User.findOne({ mobile: String(mobile).trim() });
    if (!user) {
      return res.status(401).json({ message: 'Invalid mobile or password' });
    }

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: 'Invalid mobile or password' });
    }

    if (user.role === 'admin') {
      return res.status(403).json({
        message: 'Use admin login for administrator accounts',
      });
    }

    const token = signToken(user);
    return res.json({
      token,
      user: userResponse(user),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Login failed' });
  }
}

async function adminLogin(req, res) {
  try {
    const { mobile, password } = req.body;
    if (!mobile || !password) {
      return res.status(400).json({ message: 'mobile and password are required' });
    }

    const user = await User.findOne({ mobile: String(mobile).trim() });
    if (!user) {
      return res.status(401).json({ message: 'Invalid admin credentials' });
    }

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: 'Invalid admin credentials' });
    }

    if (user.role !== 'admin') {
      return res.status(403).json({ message: 'Not an administrator' });
    }

    const token = signToken(user);
    return res.json({
      token,
      user: userResponse(user),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Admin login failed' });
  }
}

module.exports = { register, login, adminLogin };
