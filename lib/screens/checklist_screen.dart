import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<String> _defaultItems = [
    'Drill Arm ASM',
    '2 air drills',
    'Hose with gauge',
    'Drill cable',
    '3 drill arm mounting brackets',
    '7 drill bits',
    '24" hardline',
    'water bottles',
    'Bag of air fittings',
    'Camera arm bracket',
    'Pack of zip ties',
    '4 jobsite markers',
    '2 European air fittings',
    '3000 PSI Guage for hydrostatic',
    '4 Gas detectors',
    '4 Gas detector hoses',
    '8 double A Batteries',
    '1 Yellow paint marker',
    '7 pack of ORings',
    '3 Milwaukee batteries',
    'Battery charger',
    '60 Foot endoscope',
    '2 Diiwak endoscope camera',
    'DJI Mimi Action 4',
    '3 Lights for action 4',
    'Explosion proof phone',
    'Explosion proof tablet',


  ];

  List<String> _items = [];
  Set<int> _checked = {};
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(_defaultItems); // preload default list
    _loadChecklistState();
  }

  Future<void> _loadChecklistState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedChecked = prefs.getStringList('checklist_checked') ?? [];
    final savedItems = prefs.getStringList('checklist_items');

    setState(() {
      _items = savedItems ?? _items;
      _checked = savedChecked.map(int.parse).toSet();
    });
  }

  Future<void> _saveChecklistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checklist_checked', _checked.map((e) => e.toString()).toList());
    await prefs.setStringList('checklist_items', _items);
  }

  void _toggleCheck(int index) {
    setState(() {
      _checked.contains(index) ? _checked.remove(index) : _checked.add(index);
    });
    _saveChecklistState();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add(text);
        _controller.clear();
      });
      _saveChecklistState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('<', style: TextStyle(fontSize: 16)),
        ),
        title: const Text('Checklist'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Add item'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, index) {
                return CheckboxListTile(
                  title: Text(_items[index]),
                  value: _checked.contains(index),
                  onChanged: (_) => _toggleCheck(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
