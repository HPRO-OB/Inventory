class ItemRecord {
  final String itemName;
  final String partNumber;
  final int quantity;
  final String? description;

  ItemRecord({
    required this.itemName,
    required this.partNumber,
    required this.quantity,
    this.description,
  });

  factory ItemRecord.fromRow(List<String> row) {
    return ItemRecord(
      itemName: row.length > 2 ? row[2] : '',
      partNumber: row.length > 4 ? row[4] : '',
      quantity: int.tryParse(row.length > 1 ? row[1] : '0') ?? 0,
      description: row.length > 7 ? row[7] : '',
    );
  }

  List<String> toRow() {
    return [
      '', // index placeholder
      quantity.toString(),
      itemName,
      '', // blank row 3
      partNumber,
      '', // blank row 5
      description ?? '',
    ];
  }
}
