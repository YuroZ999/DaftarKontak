import 'package:flutter/material.dart';

import '../helpers/isar_helper.dart';
import '../helpers/sqflite_helper.dart';
import '../models/contact_isar_model.dart';
import '../models/contact_sqflite_model.dart';
import 'form_screen.dart';

/// Halaman utama yang menampilkan daftar kontak dari SQLite (sqflite).
///
/// - Data diambil dari [SqfliteHelper.getContacts] menggunakan FutureBuilder.
/// - Setiap item menampilkan nama, telepon, dan ikon hapus.
/// - FloatingActionButton menuju halaman tambah kontak.
/// - Ikon terminal di AppBar untuk trigger uji coba fungsi Isar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SqfliteHelper _sqfliteHelper = SqfliteHelper.instance;
  final IsarHelper _isarHelper = IsarHelper.instance;

  late Future<List<ContactSqflite>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    _contactsFuture = _sqfliteHelper.getContacts();
  }

  Future<void> _refresh() async {
    setState(_loadContacts);
  }

  /// Uji coba fungsi Isar di terminal (debug trigger).
  Future<void> _testIsar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menjalankan uji coba Isar...')),
    );

    // Tambahkan satu data contoh ke Isar.
    await _isarHelper.putContact(
      ContactIsar(
        name: 'Isar Test ${DateTime.now().second}',
        phone: '0812-0000-0001',
        email: 'isartest@example.com',
      ),
    );

    // Baca semua data dari Isar.
    final List<ContactIsar> all = await _isarHelper.getAllContacts();

    // Tampilkan ke konsol / terminal.
    // ignore: avoid_print
    print('=== UJI COBA ISAR ===');
    for (final c in all) {
      // ignore: avoid_print
      print('Isar: ${c.id} - ${c.name} - ${c.phone} - ${c.email}');
    }
    // ignore: avoid_print
    print('Total kontak di Isar: ${all.length}');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Isar OK! ${all.length} kontak tercatat. Cek terminal.',
        ),
      ),
    );
  }

  Future<void> _deleteContact(ContactSqflite contact) async {
    await _sqfliteHelper.deleteContact(contact.id!);
    _refresh();
  }

  Future<void> _openForm({ContactSqflite? contact}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FormScreen(contact: contact),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
        actions: [
          IconButton(
            tooltip: 'Uji coba Isar di terminal',
            icon: const Icon(Icons.terminal),
            onPressed: _testIsar,
          ),
        ],
      ),
      body: FutureBuilder<List<ContactSqflite>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const Center(
              child: Text('Belum ada kontak.\nTekan tombol + untuk menambah.'),
            );
          }

          return ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(c.name),
                subtitle: Text('${c.phone}\n${c.email}'),
                isThreeLine: true,
                onTap: () => _openForm(contact: c),
                trailing: IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteContact(c),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Kontak',
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
