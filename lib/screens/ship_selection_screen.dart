import 'package:flutter/material.dart';
import 'package:ship_inventory/shared/item_record.dart';
import 'package:ship_inventory/shared/sheet_api.dart';
import 'home_screen.dart';

class ShipSelectionScreen extends StatefulWidget {
  final Function(String) onSheetSelected;

  const ShipSelectionScreen({
    super.key,
    required this.onSheetSelected,
  });

  @override
  State<ShipSelectionScreen> createState() => _ShipSelectionScreenState();
}

class _ShipSelectionScreenState extends State<ShipSelectionScreen> {
  late Future<List<String>> _sheetTabs;

  @override
  void initState() {
    super.initState();
    _sheetTabs = _loadSheetTabs();
  }

  Future<List<String>> _loadSheetTabs() async {
    await SheetApi.init(); // ✅ ensures spreadsheet is ready
    return SheetApi.getSheetTitles();
  }

  void _onSheetSelected(String selectedSheet) async {
    final List<ItemRecord> items = await SheetApi.getItems(selectedSheet);
    if (!mounted) return;

    widget.onSheetSelected(selectedSheet);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          selectedSheet: selectedSheet,
          items: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Ship'),
      ),
      body: FutureBuilder<List<String>>(
        future: _sheetTabs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tabs = snapshot.data!;
            return ListView.builder(
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tabs[index]),
                  onTap: () => _onSheetSelected(tabs[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
