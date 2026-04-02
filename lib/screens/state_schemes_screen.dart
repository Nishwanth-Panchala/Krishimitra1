import 'package:flutter/material.dart';

import '../models/scheme.dart';
import 'schemes_list_screen.dart';

class StateSchemesScreen extends StatelessWidget {
  const StateSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SchemesListScreen(
      filterType: SchemeType.state,
      title: 'State Schemes',
    );
  }
}

