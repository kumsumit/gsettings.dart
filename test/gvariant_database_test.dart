import 'dart:io';
import 'dart:typed_data';

import 'package:gsettings/src/gvariant_database.dart';
import 'package:test/test.dart';

void main() {
  test('lookup on an empty GVariant database returns null', () async {
    final tempDir = Directory.systemTemp.createTempSync('gsettings_test_');
    try {
      final file = File('${tempDir.path}/empty.gvariantdb');

      // Create a valid GVariant database with an empty root table.
      // Header is 24 bytes: signature0, signature1, version, rootStart, rootEnd.
      final rootTable = ByteData(8);
      rootTable.setUint32(0, 0, Endian.little); // nBloomWords = 0
      rootTable.setUint32(4, 0, Endian.little); // nBuckets = 0

      final data = ByteData(24 + rootTable.lengthInBytes);
      data.setUint32(0, 1918981703, Endian.little);
      data.setUint32(4, 1953390953, Endian.little);
      data.setUint32(8, 0, Endian.little);
      data.setUint32(16, 24, Endian.little);
      data.setUint32(20, 24 + rootTable.lengthInBytes, Endian.little);
      for (var i = 0; i < rootTable.lengthInBytes; i++) {
        data.setUint8(24 + i, rootTable.getUint8(i));
      }

      await file.writeAsBytes(data.buffer.asUint8List());

      final db = GVariantDatabase(file.path);
      final value = await db.lookup('/some/key');
      expect(value, isNull);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
