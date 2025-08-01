import 'package:flutter/material.dart';
import 'package:ship_inventory/shared/item_record.dart';
import 'package:ship_inventory/screens/update_screen.dart';
import 'package:ship_inventory/shared/sheet_api.dart';

class SearchScreen extends StatefulWidget {
  final String selectedSheet;
  final List<ItemRecord> items;

  const SearchScreen({
    super.key,
    required this.selectedSheet,
    required this.items,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<ItemRecord> _items;

  @override
  void initState() {
    super.initState();
    _searchController.clear();
    _items = List.from(widget.items); // Create a mutable copy
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUpdateScreen(ItemRecord record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateScreen(
          record: record,
          selectedSheet: widget.selectedSheet,
        ),
      ),
    );

    // Re-fetch items from Google Sheets after returning
    final updatedItems = await SheetApi.getItems(widget.selectedSheet);
    setState(() {
      _items = List.from(updatedItems);
      _searchController.clear(); // Optionally reset search
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredItems = _items.where((item) {
      final name = item.itemName.toLowerCase();
      final part = item.partNumber.toLowerCase();
      return name.contains(query) || part.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('<', style: TextStyle(fontSize: 16)),
        ),
        title: const Text('Search Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by item or part number',
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item.itemName),
                    subtitle: Text('Part #: ${item.partNumber} | Qty: ${item.quantity}'),
                    onTap: () => _openUpdateScreen(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
