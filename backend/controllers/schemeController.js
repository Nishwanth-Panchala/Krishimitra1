const Scheme = require('../models/Scheme');

async function listAll(req, res) {
  try {
    const schemes = await Scheme.find().sort({ createdAt: -1 }).lean();
    const mapped = schemes.map((s) => {
      const id = s._id.toString();
      return {
        id,
        scheme_name: s.scheme_name,
        scheme_type: s.scheme_type,
        state: s.state ?? '',
        basic_info: s.description ?? '',
        description: s.description ?? '',
        benefits: s.benefits ?? [],
        application_link: s.application_link ?? '',
        last_date: s.last_date ?? '',
      };
    });
    return res.json(mapped);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load schemes' });
  }
}

async function create(req, res) {
  try {
    const {
      scheme_name,
      scheme_type,
      state,
      description,
      benefits,
      application_link,
      last_date,
    } = req.body;

    if (!scheme_name || !scheme_type) {
      return res.status(400).json({ message: 'scheme_name and scheme_type are required' });
    }

    const typeNorm = String(scheme_type).toLowerCase().includes('central')
      ? 'Central'
      : 'State';

    const scheme = await Scheme.create({
      scheme_name: String(scheme_name).trim(),
      scheme_type: typeNorm,
      state: state ?? '',
      description: description ?? '',
      benefits: Array.isArray(benefits) ? benefits : [],
      application_link: application_link ?? '',
      last_date: last_date ?? '',
      createdBy: req.user.sub,
    });

    const json = scheme.toJSON();
    return res.status(201).json({
      id: json.id,
      scheme_name: json.scheme_name,
      scheme_type: json.scheme_type,
      state: json.state,
      basic_info: json.basic_info,
      benefits: json.benefits,
      application_link: json.application_link,
      last_date: json.last_date,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to create scheme' });
  }
}

async function listByType(req, res) {
  try {
    const raw = (req.params.type || '').toLowerCase();
    const scheme_type = raw.includes('central') ? 'Central' : 'State';
    const schemes = await Scheme.find({ scheme_type }).sort({ createdAt: -1 }).lean();
    const mapped = schemes.map((s) => ({
      id: s._id.toString(),
      scheme_name: s.scheme_name,
      scheme_type: s.scheme_type,
      state: s.state ?? '',
      basic_info: s.description ?? '',
      benefits: s.benefits ?? [],
      application_link: s.application_link ?? '',
      last_date: s.last_date ?? '',
    }));
    return res.json(mapped);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to filter schemes' });
  }
}

async function listByState(req, res) {
  try {
    const state = decodeURIComponent(req.params.state || '').trim();
    if (!state) {
      return res.status(400).json({ message: 'state is required' });
    }
    const schemes = await Scheme.find({
      scheme_type: 'State',
      state: new RegExp(`^${state.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, 'i'),
    })
      .sort({ createdAt: -1 })
      .lean();

    const mapped = schemes.map((s) => ({
      id: s._id.toString(),
      scheme_name: s.scheme_name,
      scheme_type: s.scheme_type,
      state: s.state ?? '',
      basic_info: s.description ?? '',
      benefits: s.benefits ?? [],
      application_link: s.application_link ?? '',
      last_date: s.last_date ?? '',
    }));
    return res.json(mapped);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to filter schemes by state' });
  }
}

module.exports = { listAll, create, listByType, listByState };
