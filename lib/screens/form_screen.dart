import 'package:flutter/material.dart';

import '../helpers/sqflite_helper.dart';
import '../models/contact_sqflite_model.dart';

/// Halaman form untuk menambah (Create) atau mengedit (Update) kontak.
///
/// - Jika [contact] dikirim (tidak null), field akan terisi otomatis (mode Edit).
/// - Jika [contact] null, form kosong untuk kontak baru (mode Tambah).
/// - Tombol 'Simpan' memanggil insert / update dari SqfliteHelper lalu kembali.
class FormScreen extends StatefulWidget {
  final ContactSqflite? contact;

  const FormScreen({super.key, this.contact});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final SqfliteHelper _helper = SqfliteHelper.instance;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    // Mode Edit: isi field otomatis dari data kontak yang dikirim.
    final c = widget.contact;
    if (c != null) {
      _nameController.text = c.name;
      _phoneController.text = c.phone;
      _emailController.text = c.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (_isEditing) {
      // ===== UPDATE =====
      final updated = ContactSqflite(
        id: widget.contact!.id,
        name: name,
        phone: phone,
        email: email,
      );
      await _helper.updateContact(updated);
    } else {
      // ===== INSERT =====
      final newContact = ContactSqflite(
        name: name,
        phone: phone,
        email: email,
      );
      await _helper.insertContact(newContact);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Kontak' : 'Tambah Kontak Baru';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  final email = value.trim();
                  final valid = RegExp(
                    r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$',
                  ).hasMatch(email);
                  if (!valid) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
