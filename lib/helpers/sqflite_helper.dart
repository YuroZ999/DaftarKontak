import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/contact_sqflite_model.dart';

/// Helper (singleton) untuk mengelola operasi CRUD database SQLite
/// menggunakan package `sqflite`.
///
/// Pola singleton memastikan hanya ada satu koneksi Database yang dibuka,
/// lalu dipakai ulang (cache) di seluruh aplikasi.
class SqfliteHelper {
  SqfliteHelper._privateConstructor();

  static final SqfliteHelper instance = SqfliteHelper._privateConstructor();

  static Database? _database;

  /// Nama tabel dan kolom.
  static const String _tableName = 'contacts';

  /// Getter untuk mengakses database (lazily initialized).
  Future<Database> get database async {
    // Jika sudah ada, langsung pakai (cache).
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Membuka (atau membuat) database dan tabel contacts.
  Future<Database> _initDatabase() async {
    // Lokasi database di direktori dokumen aplikasi.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contact_manager.db');

    return openDatabase(
      path,
      version: 1,
      // onCreate hanya dipanggil saat database pertama kali dibuat.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ===================== CREATE =====================

  /// Menambahkan kontak baru ke tabel.
  /// Mengembalikan id baris yang baru dibuat.
  Future<int> insertContact(ContactSqflite contact) async {
    final db = await database;
    return db.insert(_tableName, contact.toMap());
  }

  // ===================== READ =====================

  /// Mengambil semua kontak, diurutkan berdasarkan nama.
  Future<List<ContactSqflite>> getContacts() async {
    final db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );
    return rows.map((row) => ContactSqflite.fromMap(row)).toList();
  }

  /// Mengambil satu kontak berdasarkan id.
  Future<ContactSqflite?> getContactById(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ContactSqflite.fromMap(rows.first);
  }

  // ===================== UPDATE =====================

  /// Memperbarui data kontak berdasarkan id.
  /// Mengembalikan jumlah baris yang diperbarui.
  Future<int> updateContact(ContactSqflite contact) async {
    final db = await database;
    return db.update(
      _tableName,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // ===================== DELETE =====================

  /// Menghapus kontak berdasarkan id.
  /// Mengembalikan jumlah baris yang dihapus.
  Future<int> deleteContact(int id) async {
    final db = await database;
    return db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Menutup koneksi database (opsional, dipanggil saat aplikasi ditutup).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
