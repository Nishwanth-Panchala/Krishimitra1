import 'package:flutter/material.dart';

import '../models/scheme.dart';

class SchemeEditorDialog extends StatefulWidget {
  final Scheme? initial;

  const SchemeEditorDialog({super.key, this.initial});

  @override
  State<SchemeEditorDialog> createState() => _SchemeEditorDialogState();
}

class _SchemeEditorDialogState extends State<SchemeEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late SchemeType _schemeType;
  late String _schemeName;
  late String _basicInfo;
  late String _applicationLink;
  late String _lastDate;
  late String _state;
  late String _benefitsText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _schemeType = initial?.schemeType ?? SchemeType.state;
    _schemeName = initial?.schemeName ?? '';
    _basicInfo = initial?.basicInfo ?? '';
    _applicationLink = initial?.applicationLink ?? '';
    _lastDate = initial?.lastDate ?? '';
    _state = initial?.state ?? '';
    _benefitsText = (initial?.benefits ?? const []).join('\n');
  }

  List<String> _parseBenefits(String raw) {
    final parts = raw.split(RegExp(r'[,\\n]'));
    return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Scheme' : 'Add Scheme'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              DropdownButtonFormField<SchemeType>(
                initialValue: _schemeType,
                decoration: const InputDecoration(
                  labelText: 'Scheme Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(
                    value: SchemeType.state,
                    child: Text('State'),
                  ),
                  DropdownMenuItem(
                    value: SchemeType.central,
                    child: Text('Central'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _schemeType = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _schemeName,
                decoration: const InputDecoration(
                  labelText: 'Scheme Name',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Scheme name is required';
                  return null;
                },
                onChanged: (v) => _schemeName = v,
              ),
              const SizedBox(height: 12),
              if (_schemeType == SchemeType.state) ...[
                TextFormField(
                  initialValue: _state,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'State is required for State schemes';
                    return null;
                  },
                  onChanged: (v) => _state = v,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                initialValue: _basicInfo,
                decoration: const InputDecoration(
                  labelText: 'Description (Basic Info)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Description is required';
                  return null;
                },
                onChanged: (v) => _basicInfo = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _benefitsText,
                decoration: const InputDecoration(
                  labelText: 'Benefits (one per line or comma-separated)',
                  prefixIcon: Icon(Icons.list_alt),
                ),
                maxLines: 4,
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Benefits are required';
                  return null;
                },
                onChanged: (v) => _benefitsText = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _applicationLink,
                decoration: const InputDecoration(
                  labelText: 'Application Link (URL)',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Application link is required';
                  return null;
                },
                onChanged: (v) => _applicationLink = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _lastDate,
                decoration: const InputDecoration(
                  labelText: 'Last Date',
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Last date is required';
                  return null;
                },
                onChanged: (v) => _lastDate = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final ok = _formKey.currentState?.validate() ?? false;
            if (!ok) return;

            final initial = widget.initial;
            final id = initial?.id ??
                DateTime.now().microsecondsSinceEpoch.toString();

            final updated = Scheme(
              id: id,
              schemeName: _schemeName.trim(),
              schemeType: _schemeType,
              state: _schemeType == SchemeType.state ? _state.trim() : '',
              basicInfo: _basicInfo.trim(),
              benefits: _parseBenefits(_benefitsText),
              applicationLink: _applicationLink.trim(),
              lastDate: _lastDate.trim(),
            );
            Navigator.pop(context, updated);
          },
          child: Text(isEditing ? 'Save Changes' : 'Add Scheme'),
        ),
      ],
    );
  }
}

