/// Model data untuk database SQLite (sqflite).
///
/// Kelas standar dengan properti id, name, phone, dan email.
/// Dilengkapi toMap() untuk menyimpan ke tabel dan fromMap()
/// untuk membaca dari hasil query SQLite.
class ContactSqflite {
  int? id; // auto-increment (nullable karena belum disimpan)
  String name;
  String phone;
  String email;

  ContactSqflite({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  /// Konversi objek menjadi `Map<String, Object?>` agar bisa
  /// dipakai sebagai argumen INSERT / UPDATE di sqflite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  /// Membangun objek ContactSqflite dari hasil query SQLite.
  factory ContactSqflite.fromMap(Map<String, Object?> map) {
    return ContactSqflite(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  @override
  String toString() {
    return 'ContactSqflite(id: $id, name: $name, phone: $phone, email: $email)';
  }
}
