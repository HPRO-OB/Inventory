import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _displayTime = '00:00:00';
  final List<String> _logs = [];
  final List<Map<String, dynamic>> _receipts = [];
  Duration _elapsedBeforeRestart = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDisplayTime());
    _restoreStopwatchState();
    _loadSavedLogs();
    _loadSavedReceipts();
  }

  @override
  void dispose() {
    _timer.cancel();
    _saveStopwatchState();
    _saveLogs();
    super.dispose();
  }

  void _updateDisplayTime() {
    final totalElapsed = _elapsedBeforeRestart + _stopwatch.elapsed;
    setState(() {
      _displayTime = _formatDuration(totalElapsed);
    });
  }

  String _formatDuration(Duration d) {
    return [d.inHours, d.inMinutes % 60, d.inSeconds % 60]
        .map((seg) => seg.toString().padLeft(2, '0'))
        .join(':');
  }

  Future<void> _saveLog() async {
    final label = await _showInputDialog('Label this time entry');
    if (label == null || label.trim().isEmpty) return;

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final log = '[$timestamp] $label - Time: $_displayTime';
    setState(() {
      _logs.insert(0, log);
    });

    await _saveLogs();
    await _saveStopwatchState();
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('travel_logs', _logs);
  }

  Future<void> _loadSavedLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogs = prefs.getStringList('travel_logs') ?? [];
    setState(() {
      _logs.clear();
      _logs.addAll(storedLogs);
    });
  }

  Future<void> _saveStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentElapsed = _elapsedBeforeRestart + _stopwatch.elapsed;

    await prefs.setBool('stopwatch_running', _stopwatch.isRunning);
    await prefs.setInt('stopwatch_elapsed', currentElapsed.inMilliseconds);
    if (_stopwatch.isRunning) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('stopwatch_start', now);
    }
  }

  Future<void> _restoreStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final elapsed = prefs.getInt('stopwatch_elapsed') ?? 0;
    final wasRunning = prefs.getBool('stopwatch_running') ?? false;
    final lastStart = prefs.getInt('stopwatch_start') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (wasRunning) {
      final adjustedElapsed = now - lastStart + elapsed;
      _elapsedBeforeRestart = Duration(milliseconds: adjustedElapsed);
      _stopwatch.start();
    } else {
      _elapsedBeforeRestart = Duration(milliseconds: elapsed);
    }

    _updateDisplayTime();
  }

  Future<void> _loadSavedReceipts() async {
    final dir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory('${dir.path}/receipts');
    if (await receiptDir.exists()) {
      final files = receiptDir.listSync().whereType<File>().toList();
      setState(() {
        _receipts.clear();
        for (final file in files) {
          final name = file.path.split('/').last.replaceAll('.jpg', '');
          final parts = name.split('_');
          final label = parts.skip(2).join('_'); // Skip "receipt" and date
          _receipts.add({'file': file, 'label': label});
        }
      });
    }
  }

  Future<void> _saveReceiptImage(ImageSource source) async {
    final label = await _showInputDialog('Label this receipt');
    if (label == null || label.trim().isEmpty) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory('${dir.path}/receipts');
    if (!await receiptDir.exists()) {
      await receiptDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'receipt_${timestamp}_${label.replaceAll(" ", "_")}.jpg';
    final savedImage = await File(image.path).copy('${receiptDir.path}/$fileName');

    setState(() {
      _receipts.insert(0, {'file': savedImage, 'label': label});
    });
  }

  Future<String?> _showInputDialog(String title) async {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            onChanged: (value) => input = value,
            decoration: const InputDecoration(hintText: 'Enter label'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
  leading: TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('<', style: TextStyle(fontSize: 16)),
  ),
  title: const Text('Travel'),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stopwatch:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(child: Text(_displayTime, style: const TextStyle(fontSize: 32))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start();
                    });
                    _saveStopwatchState();
                  },
                  child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _stopwatch.reset();
                      _elapsedBeforeRestart = Duration.zero;
                      _updateDisplayTime();
                    });
                    _saveStopwatchState();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveLog,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Saved Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_logs[index]));
              },
            ),
            const Divider(height: 32),
            const Text('Receipts:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _saveReceiptImage(ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _saveReceiptImage(ImageSource.gallery),
                  child: const Text('Choose File'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _receipts.length,
              itemBuilder: (context, index) {
                final receipt = _receipts[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.file(receipt['file']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Label: ${receipt['label']}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
