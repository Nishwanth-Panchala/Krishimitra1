import 'package:flutter/material.dart';

import '../models/scheme.dart';
import 'schemes_list_screen.dart';

class CentralSchemesScreen extends StatelessWidget {
  const CentralSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SchemesListScreen(
      filterType: SchemeType.central,
      title: 'Central Schemes',
    );
  }
}

