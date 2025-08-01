import 'package:flutter/material.dart';
import 'package:ship_inventory/screens/ship_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ship Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const ShipSelectionScreen(
        onSheetSelected: _noop,
      ),
    );
  }

  static void _noop(String _) {}
}
