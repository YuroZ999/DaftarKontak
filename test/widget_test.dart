// Test sederhana untuk model data (murni Dart, tanpa plugin platform).

import 'package:flutter_test/flutter_test.dart';

import 'package:contact_manager/models/contact_sqflite_model.dart';

void main() {
  group('ContactSqflite', () {
    test('toMap dan fromMap harus round-trip', () {
      final contact = ContactSqflite(
        id: 1,
        name: 'Arafly',
        phone: '0812345',
        email: 'arafly@example.com',
      );

      final map = contact.toMap();
      expect(map['name'], 'Arafly');
      expect(map['phone'], '0812345');
      expect(map['email'], 'arafly@example.com');

      final restored = ContactSqflite.fromMap(map);
      expect(restored.id, 1);
      expect(restored.name, 'Arafly');
      expect(restored.phone, '0812345');
      expect(restored.email, 'arafly@example.com');
    });
  });
}
