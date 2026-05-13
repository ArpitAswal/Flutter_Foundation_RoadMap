import 'package:flutter/material.dart';
import 'presentation/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/hive_product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Global Services
  await Hive.initFlutter();
  // Register Hive Adapters
  Hive.registerAdapter(HiveProductAdapter());
  
  runApp(const LocalStorageApp());
}

class LocalStorageApp extends StatelessWidget {
  const LocalStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Storage Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
