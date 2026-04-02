import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/scheme.dart';

class SchemesLocalDataSource {
  static const String _assetPath = 'lib/data/schemes.json';

  Future<List<Scheme>> loadSchemes() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Scheme.fromJson(e))
          .toList();
    }

    throw const FormatException('schemes.json must be a JSON array');
  }
}

