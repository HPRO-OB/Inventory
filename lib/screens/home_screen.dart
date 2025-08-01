import 'package:flutter/material.dart';
import 'package:ship_inventory/screens/checklist_screen.dart';
import 'package:ship_inventory/screens/notes_screen.dart';
import 'package:ship_inventory/screens/pdf_screen.dart';
import 'package:ship_inventory/screens/search_screen.dart';
import 'package:ship_inventory/screens/travel_screen.dart';
import 'package:ship_inventory/shared/item_record.dart';

class HomeScreen extends StatelessWidget {
  final String selectedSheet;
  final List<ItemRecord> items;

  const HomeScreen({
    super.key,
    required this.selectedSheet,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ship: $selectedSheet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(
                      selectedSheet: selectedSheet,
                      items: items,
                    ),
                  ),
                );
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChecklistScreen(),
                  ),
                );
              },
              child: const Text('Checklist'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
              child: const Text('Notes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PdfScreen()),
                );
              },
              child: const Text('Documents'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelScreen()),
                );
              },
              child: const Text('Travel'),
            ),
          ],
        ),
      ),
    );
  }
}
