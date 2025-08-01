import 'package:gsheets/gsheets.dart';
import 'package:ship_inventory/shared/item_record.dart';
import 'package:flutter/services.dart' show rootBundle;


class SheetApi {
  static const _spreadsheetId = '1WqqgD4HyB4diccZrOQyDUa3gEjRRcXKbP4xfIy7Jfls';
  static const _credentialsPath = 'assets/credentials.json';
  static late GSheets _gsheets;
  static late Spreadsheet _spreadsheet;

  static Future<void> init() async {
    final credentials = await rootBundle.loadString(_credentialsPath);
    _gsheets = GSheets(credentials);
    _spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
  }

  static Future<List<String>> getSheetTitles() async {
    return _spreadsheet.sheets.map((sheet) => sheet.title).toList();
  }

  static Future<Worksheet?> getSheetByTitle(String title) async {
    return _spreadsheet.worksheetByTitle(title);
  }

  static Future<List<ItemRecord>> getItems(String sheetTitle) async {
    final sheet = await getSheetByTitle(sheetTitle);
    if (sheet == null) return [];

    final rows = await sheet.values.allRows();
    if (rows.length < 2) return [];

    // Skip header and possible metadata
    final dataRows = rows.skip(2).toList();

    return dataRows
        .where((row) => row.length > 1 && row[1].trim().isNotEmpty)
        .map(ItemRecord.fromRow)
        .toList();
  }

  static Future<void> updateItemQuantity(String sheetTitle, String partNumber, int newQuantity) async {
    final sheet = await getSheetByTitle(sheetTitle);
    if (sheet == null) return;

    final rows = await sheet.values.allRows();
    if (rows.isEmpty) return;

    for (int i = 0; i < rows.length; i++) {
      if (rows[i].length > 4 && rows[i][4] == partNumber) {
        await sheet.values.insertValue(newQuantity.toString(), column: 2, row: i + 1);
        break;
      }
    }
  }

  static Future<void> updateDescription(String sheetTitle, String partNumber, String description) async {
    final sheet = await getSheetByTitle(sheetTitle);
    if (sheet == null) return;

    final rows = await sheet.values.allRows();
    if (rows.isEmpty) return;

    for (int i = 0; i < rows.length; i++) {
      if (rows[i].length > 4 && rows[i][4] == partNumber) {
        await sheet.values.insertValue(description, column: 8, row: i + 1);
        break;
      }
    }
  }
}
