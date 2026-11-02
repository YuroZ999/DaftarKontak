import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/contact_isar_model.dart';

/// Helper untuk mengelola operasi CRUD database Isar (NoSQL).
///
/// Kelas ini menginisialisasi koneksi Isar dan menyediakan metode CRUD
/// berbasis objek (tanpa SQL) untuk perbandingan sintaks dengan sqflite.
class IsarHelper {
  IsarHelper._privateConstructor();

  static final IsarHelper instance = IsarHelper._privateConstructor();

  late Future<Isar> _dbFuture;

  /// Memanggil [init] sekali di awal aplikasi (main).
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        ContactIsarSchema,
      ],
      directory: dir.path,
      name: 'contact_isar',
    );
    _dbFuture = Future.value(isar);
  }

  /// Getter database Isar (lazily, pastikan [init] sudah dipanggil).
  Future<Isar> get db => _dbFuture;

  // ===================== CREATE / UPDATE (PUT) =====================

  /// Isar menggunakan satu metode `put` untuk CREATE dan UPDATE.
  /// Jika [contact] belum punya id, akan dibuat baru (auto increment).
  Future<Id> putContact(ContactIsar contact) async {
    final isar = await db;
    return isar.writeTxn(
      () => isar.contactIsars.put(contact),
    );
  }

  // ===================== READ =====================

  /// Mengambil semua kontak dari Isar.
  Future<List<ContactIsar>> getAllContacts() async {
    final isar = await db;
    return isar.contactIsars.where().sortByPhone().findAll();
  }

  /// Mengambil satu kontak berdasarkan id.
  Future<ContactIsar?> getContactById(Id id) async {
    final isar = await db;
    return isar.contactIsars.get(id);
  }

  // ===================== DELETE =====================

  /// Menghapus kontak berdasarkan id.
  Future<void> deleteContact(Id id) async {
    final isar = await db;
    await isar.writeTxn(
      () => isar.contactIsars.delete(id),
    );
  }

  /// Menutup koneksi Isar.
  Future<void> close() async {
    final isar = await _dbFuture;
    await isar.close();
  }
}
