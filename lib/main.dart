import 'package:flutter/material.dart';

import 'helpers/isar_helper.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database Isar sebelum aplikasi berjalan.
  await IsarHelper.instance.init();

  runApp(const ContactManagerApp());
}

class ContactManagerApp extends StatelessWidget {
  const ContactManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
