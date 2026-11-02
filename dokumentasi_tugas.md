# Laporan Teknis: Perbandingan sqflite (SQLite) vs Isar di Flutter

**Project** : Contact Manager (Daftar Kontak)
**Teknologi** : Flutter + Dart 3.13
**Database** : `sqflite` (SQL relasional) dan `isar_community` (NoSQL/objek)

---

## 1. Pendahuluan

Aplikasi **Daftar Kontak** dibangun di Flutter dengan fitur CRUD (Create, Read,
Update, Delete) untuk data kontak (nama, nomor telepon, email). Untuk memenuhi
tugas perbandingan, aplikasi menggunakan **dua teknologi penyimpanan lokal**
secara bersamaan:

1. **sqflite** — plugin Flutter yang membungkus SQLite, database relasional
   berbasis SQL. Digunakan sebagai database utama dan terhubung penuh ke UI.
2. **Isar** (`isar_community`) — database NoSQL berorientasi objek yang sangat
   cepat. Dipakai sebagai penyimpanan alternatif untuk diperbandingkan, dengan
   mekanisme uji coba terpisah (debug trigger di terminal).

Kedua teknologi diimplementasikan pada model data dan helper CRUD yang
terpisah, sehingga sintaksnya dapat dibandingkan langsung.

---

## 2. Perbandingan Tahap Setup dan Inisialisasi

### 2.1 Dependencies (`pubspec.yaml`)

| sqflite                          | Isar                                   |
|----------------------------------|----------------------------------------|
| `sqflite`                        | `isar_community`                       |
| `path` (gabung path file db)     | `isar_community_flutter_libs` (binari) |
|                                  | `isar_community_generator` (dev)       |
|                                  | `build_runner` (dev)                   |

> **Catatan setup Isar**: package `isar` resmi sudah lama tidak di-update dan
> tidak kompatibel dengan Dart 3.13. Karena itu digunakan fork komunitas
> `isar_community` yang memiliki API identik dan tetap mendukung Dart modern.
> Nama dependency berbeda, tetapi semua kode (import, anotasi, koleksi) sama
> persis dengan `isar`.

### 2.2 Inisialisasi

**sqflite** — cukup buka koneksi `openDatabase` dan buat tabel dengan SQL
`CREATE TABLE` (sekali saja di `onCreate`):

```dart
final path = join(await getDatabasesPath(), 'contact_manager.db');
_database = await openDatabase(path, version: 1, onCreate: ...);
```

**Isar** — butuh *code generation* terlebih dahulu untuk menghasilkan file
`.g.dart`, lalu baru dibuka:

```bash
dart run build_runner build --delete-conflicting-outputs
```

```dart
final dir = await getApplicationDocumentsDirectory();
_imageIsar = await Isar.open([ContactIsarSchema], directory: dir.path);
```

| Aspek                  | sqflite        | Isar                     |
|------------------------|----------------|--------------------------|
| Jumlah dependency      | 2              | 4 (termasuk codegen)     |
| Perlu code generator   | ❌ Tidak       | ✅ Ya (`build_runner`)   |
| Konsep inisialisasi    | Buka DB + buat tabel SQL | Buka DB berisi collection |

**Kesimpulan setup**: sqflite lebih cepat karena tanpa tahap code generation.
Isar memerlukan anotasi `@collection` dan menjalankan `build_runner`, namun
proses ini otomatis dan hasilnya (`.g.dart`) tidak ditulis manual.

---

## 3. Perbandingan Struktur Kode (Sintaks) CRUD

### 3.1 Model Data

**sqflite** — kelas Dart biasa dengan manual `toMap()` / `fromMap()`:

```dart
class ContactSqflite {
  int? id;
  String name, phone, email;

  Map<String, Object?> toMap() => {'id': id, 'name': name, 'phone': phone, 'email': email};
  factory ContactSqflite.fromMap(Map<String, Object?> map) => ...;
}
```

**Isar** — kelas dianotasi `@collection`, `Id` dikelola otomatis, kode
serialisasi dihasilkan oleh generator:

```dart
@collection
class ContactIsar {
  Id id = Isar.autoIncrement;
  String name;
  String phone;
  String email;
}
```

### 3.2 Create

| Teknologi  | Sintaks                                                        |
|------------|----------------------------------------------------------------|
| sqflite    | `db.insert('contacts', contact.toMap());`                     |
| Isar       | `isar.writeTxn(() => isar.contactIsars.put(contact));`        |

### 3.3 Read (semua data)

| Teknologi  | Sintaks                                                        |
|------------|----------------------------------------------------------------|
| sqflite    | `db.query('contacts', orderBy: 'name ASC')` → map ke objek     |
| Isar       | `isar.contactIsars.where().sortByPhone().findAll()`            |

### 3.4 Update

| Teknologi  | Sintaks                                                        |
|------------|----------------------------------------------------------------|
| sqflite    | `db.update('contacts', map, where: 'id = ?', whereArgs: [id])`|
| Isar       | `put()` lagi dengan objek yang sudah ber-`Id` (upsert)         |

### 3.5 Delete

| Teknologi  | Sintaks                                                        |
|------------|----------------------------------------------------------------|
| sqflite    | `db.delete('contacts', where: 'id = ?', whereArgs: [id])`     |
| Isar       | `isar.writeTxn(() => isar.contactIsars.delete(id));`          |

### 3.6 Ringkasan perbedaan sintaks

| Aspek               | sqflite (Relasional/SQL)      | Isar (NoSQL/OObjek)            |
|---------------------|-------------------------------|--------------------------------|
| Query               | String SQL / penjual `/ ?`     | Query builder berantai (`.where().sortBy().findAll()`) |
| Mapping data        | Manual (`toMap`/`fromMap`)     | Otomatis oleh generator         |
| Write (insert/update) | Operasi terpisah (`insert` vs `update`) | Satu metode `put` (upsert) |
| Transaksi           | Manual bila perlu              | `writeTxn(...)` bawaan          |
| Relasi antar tabel  | `JOIN` SQL                     | Link/Backlink (belum dipakai)   |
| Keamanan tipe       | Lemah (`Map<String, Object?>`) | Kuat (objek ter-typing)         |

---

## 4. Hasil Pengujian

- `dart analyze` : ✅ tanpa error.
- `flutter test` : ✅ semua test model lolos.
- File hasil generate Isar `lib/models/contact_isar_model.g.dart` : ✅ berhasil.

> Aplikasi dapat dijalankan di Android/iOS dengan `flutter run`. Uji coba Isar
> dilakukan lewat ikon **Terminal** di AppBar — hasilnya dicetak ke konsol.

---

## 5. Kesimpulan: Kelebihan, Kekurangan, dan Rekomendasi

### 5.1 sqflite (SQLite)

**Kelebihan**
- Sudah matang dan didokumentasikan dengan baik.
- Standar SQL yang dikenal luas; mudah untuk query kompleks (JOIN, filter, agregasi).
- Tanpa code generation → setup cepat.

**Kekurangan**
- Kode CRUD relatif verbose: harus menulis SQL, `toMap`/`fromMap`, dan `whereArgs`.
- Tidak aman *type-safe* (data lewat `Map`).
- Performa kurang optimal untuk data dan query yang sangat sederhana.

### 5.2 Isar (NoSQL)

**Kelebihan**
- CRUD sangat ringkas dan berorientasi objek (`put`, `where().findAll()`).
- Type-safe penuh; serialisasi otomatis lewat code generation.
- Performa sangat cepat (mendekati native binary).
- Ada transaksi `writeTxn` bawaan dan index otomatis.

**Kekurangan**
- Membutuhkan `build_runner` (code generation) — setup lebih rumit.
- Package resmi `isar` tidak terawat; perlu fork `isar_community`.
- Query berbasis builder kurang natural untuk analitik/query kompleks.

### 5.3 Rekomendasi Use-Case

- **Pilih sqflite** jika aplikasi menuntut query SQL yang kompleks, banyak
  relasi antar tabel, atau tim sudah terbiasa dengan SQL. Cocok untuk aplikasi
  berbasis data turunan (laporan, transaksi, dsb.).
- **Pilih Isar** jika kebutuhan menyimpan data sederhana-ke-menengah yang
  sering diakses, mengutamakan kecepatan dan kemudahan kode (misalnya kontak,
  catatan, cache, data terstruktur kecil). Sangat pas untuk aplikasi yang
  berorientasi objek seperti *Contact Manager* ini.

**Kesimpulan akhir**: tidak ada yang "lebih baik" secara mutlak — sqflite
unggul pada kompleksitas query dan kematangan, sedangkan Isar unggul pada
kesederhanaan sintaks, kecepatan, dan keamanan tipe. Pemilihan bergantung pada
kebutuhan proyek.
