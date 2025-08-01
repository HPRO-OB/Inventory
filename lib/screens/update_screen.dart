import 'package:flutter/material.dart';
import 'package:ship_inventory/shared/item_record.dart';
import 'package:ship_inventory/shared/sheet_api.dart';

class UpdateScreen extends StatefulWidget {
  final ItemRecord record;
  final String selectedSheet;

  const UpdateScreen({
    super.key,
    required this.record,
    required this.selectedSheet,
  });

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.record.quantity.toString();
    _descriptionController.text = widget.record.description ?? '';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    final quantity = int.tryParse(_quantityController.text.trim());
    final description = _descriptionController.text.trim();

    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid quantity')),
      );
      return;
    }

    await SheetApi.updateItemQuantity(widget.selectedSheet, widget.record.partNumber, quantity);

    if (description.isNotEmpty) {
      await SheetApi.updateDescription(widget.selectedSheet, widget.record.partNumber, description);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
  leading: TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('<', style: TextStyle(fontSize: 16)),
  ),
  title: const Text('Update Item'),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.record.itemName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text('Part #: ${widget.record.partNumber}'),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Quantity',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitUpdate,
              child: const Text('Update Part'),
            ),
          ],
        ),
      ),
    );
  }
}
