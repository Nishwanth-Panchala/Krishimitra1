import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers/app_providers.dart';
import '../models/user_profile.dart';
import '../widgets/multi_select_chips.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _acresController = TextEditingController();

  String _selectedState = 'Karnataka';
  String _selectedLanguage = 'English';
  String _selectedSoilType = 'Black';

  final Set<String> _selectedCrops = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _acresController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one crop type.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final authService = ref.read(localAuthServiceProvider);

      final mobile = _mobileController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final numberOfAcres = int.parse(_acresController.text.trim());

      final profile = UserProfile(
        mobileNumber: mobile,
        name: name,
        state: _selectedState,
        language: _selectedLanguage,
        cropTypes: _selectedCrops.toList(growable: false),
        soilType: _selectedSoilType,
        numberOfAcres: numberOfAcres,
      );

      final authData = UserAuthData(
        mobileNumber: mobile,
        password: password,
        profile: profile,
      );

      await authService.registerUser(authData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Please login.')),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mobile number is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: states
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          )
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
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          )
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
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          )
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Number of acres is required';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid number (> 0)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _isSubmitting ? 'Registering...' : 'Register',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

