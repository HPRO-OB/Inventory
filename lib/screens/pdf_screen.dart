import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final List<String> pdfFiles = [
    'Digital BCD clear cover.pdf',
    'Air Motor ASSY.pdf',
    'Pump Head ASSY.pdf',
    'Pump Model ASM.pdf',
  ];

  Future<File> _loadPdfFromAssets(String assetPath) async {
    final byteData = await rootBundle.load('assets/pdfs/$assetPath');
    final file = File('${(await getTemporaryDirectory()).path}/$assetPath');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  void _openPdf(String filename) async {
    final file = await _loadPdfFromAssets(filename);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(filename)),
          body: PDFView(
            filePath: file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
          ),
        ),
      ),
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
  title: const Text('Documents'),
),
      body: ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final fileName = pdfFiles[index];
          return ListTile(
            title: Text(fileName),
            onTap: () => _openPdf(fileName),
          );
        },
      ),
    );
  }
}
