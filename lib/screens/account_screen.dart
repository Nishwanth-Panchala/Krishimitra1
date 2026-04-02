import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers/app_providers.dart';
import '../models/auth_role.dart';
import '../models/user_profile.dart';
import '../widgets/multi_select_chips.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _acresController = TextEditingController();

  String _selectedState = 'Karnataka';
  String _selectedLanguage = 'English';
  String _selectedSoilType = 'Black';
  final Set<String> _selectedCrops = {};

  @override
  void dispose() {
    _nameController.dispose();
    _acresController.dispose();
    super.dispose();
  }

  void _loadProfileIntoForm(UserProfile profile) {
    _nameController.text = profile.name;
    _acresController.text = profile.numberOfAcres.toString();
    _selectedState = profile.state;
    _selectedLanguage = profile.language;
    _selectedSoilType = profile.soilType;
    _selectedCrops
      ..clear()
      ..addAll(profile.cropTypes);
  }

  Future<void> _save(UserProfile existing) async {
    final storage = ref.read(localUserStorageProvider);

    final name = _nameController.text.trim();
    final numberOfAcres = int.tryParse(_acresController.text.trim()) ?? 0;

    if (name.isEmpty || numberOfAcres <= 0 || _selectedCrops.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill valid profile details.')),
      );
      return;
    }

    final updated = UserProfile(
      mobileNumber: existing.mobileNumber,
      name: name,
      state: _selectedState,
      language: _selectedLanguage,
      cropTypes: _selectedCrops.toList(growable: false),
      soilType: _selectedSoilType,
      numberOfAcres: numberOfAcres,
    );

    await storage.updateProfile(updated);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final roleAsync = ref.watch(authRoleProvider);

    const soilTypes = ['Black', 'Red'];
    const cropOptions = [
      'Rice',
      'Wheat',
      'Cotton',
      'Maize',
      'Pulses',
      'Sugarcane',
      'Potato',
      'Onion',
      'Tomato',
    ];
    const states = [
      'Karnataka',
      'Maharashtra',
      'Telangana',
      'Andhra Pradesh',
      'Uttar Pradesh',
      'Gujarat',
      'West Bengal',
      'Rajasthan',
      'Punjab',
      'Tamil Nadu',
    ];
    const languages = [
      'English',
      'Hindi',
      'Kannada',
      'Telugu',
      'Marathi',
      'Tamil',
      'Gujarati',
      'Bengali',
      'Punjabi',
    ];

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load: $err')),
          data: (profile) {
            if (profile == null) {
              return roleAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Text('Failed to load account: $err'),
                ),
                data: (role) {
                  if (role == AuthRole.admin) {
                    return const Center(
                      child: Text(
                        'Admin account (mock). Register a user to edit farmer profile.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'No user profile found. Please register/login first.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              );
            }

            if (!_isEditing) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Details',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Mobile: ${profile.mobileNumber}'),
                            const SizedBox(height: 6),
                            Text('Name: ${profile.name}'),
                            const SizedBox(height: 6),
                            Text('State: ${profile.state}'),
                            const SizedBox(height: 6),
                            Text('Language: ${profile.language}'),
                            const SizedBox(height: 6),
                            Text('Soil Type: ${profile.soilType}'),
                            const SizedBox(height: 6),
                            Text('Acres: ${profile.numberOfAcres}'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: profile.cropTypes
                                  .map((c) => Chip(label: Text(c)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _loadProfileIntoForm(profile);
                          setState(() => _isEditing = true);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Edit mode
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Edit Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: profile.mobileNumber,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: states
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedState = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      prefixIcon: Icon(Icons.translate),
                    ),
                    items: languages
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedLanguage = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  MultiSelectChips(
                    label: 'Crop Type (Multi-select)',
                    options: cropOptions,
                    selected: _selectedCrops,
                    onChanged: (next) => setState(() {
                      _selectedCrops
                        ..clear()
                        ..addAll(next);
                    }),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSoilType,
                    decoration: const InputDecoration(
                      labelText: 'Soil Type',
                      prefixIcon: Icon(Icons.grain),
                    ),
                    items: soilTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedSoilType = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _acresController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Acres',
                      prefixIcon: Icon(Icons.landscape),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _loadProfileIntoForm(profile);
                            setState(() => _isEditing = false);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _save(profile),
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

