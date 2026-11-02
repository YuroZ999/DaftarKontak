import 'package:isar_community/isar.dart';

part 'contact_isar_model.g.dart';

/// Collection untuk database Isar (NoSQL / local storage).
///
/// Kelas ini dianotasi dengan [@collection] agar code generator
/// (isar_community_generator) dapat membuat file `contact_isar_model.g.dart`.
///
/// ### Cara menjalankan code generator (build_runner):
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
/// atau (di project Flutter):
/// ```bash
/// flutter pub run build_runner build --delete-conflicting-outputs
/// ```
/// Perintah di atas akan menghasilkan file
/// `lib/models/contact_isar_model.g.dart` secara otomatis.
@collection
class ContactIsar {
  /// Id dikelola otomatis oleh Isar (auto increment).
  Id id = Isar.autoIncrement;

  String name;

  @Index()
  String phone;

  String email;

  ContactIsar({
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  String toString() {
    return 'ContactIsar(id: $id, name: $name, phone: $phone, email: $email)';
  }
}
