import 'package:flutter/material.dart';
import 'shared_prefs_screen.dart';
import 'hive_screen.dart';
import 'sqlite_screen.dart';
import 'drift_screen.dart';
import 'isar_screen.dart';
import 'secure_storage_screen.dart';
import '../offline_first/offline_first_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage & Offline'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Part 1: Key-Value & NoSQL',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(
            context,
            title: 'SharedPreferences',
            subtitle: 'Key-value pairs. Best for settings, tokens, flags.',
            icon: Icons.settings,
            destination: const SharedPrefsScreen(),
          ),
          _buildMenuCard(
            context,
            title: 'Hive',
            subtitle: 'Pure Dart NoSQL. Fast object caching, offline data.',
            icon: Icons.hive,
            destination: const HiveScreen(),
          ),
          _buildMenuCard(
            context,
            title: 'Isar',
            subtitle: 'High-performance NoSQL. Huge datasets, fast queries.',
            icon: Icons.speed,
            destination: const IsarScreen(),
          ),
          _buildMenuCard(
            context,
            title: 'Secure Storage',
            subtitle: 'Encrypted storage for JWT tokens and passwords.',
            icon: Icons.lock,
            destination: const SecureStorageScreen(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Part 2: SQL & Relational',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(
            context,
            title: 'SQLite (Raw)',
            subtitle: 'Embedded relational DB. Complex joins & indexing.',
            icon: Icons.storage,
            destination: const SqliteScreen(),
          ),
          _buildMenuCard(
            context,
            title: 'Drift',
            subtitle: 'Type-safe SQLite wrapper. Reactive streams & DAOs.',
            icon: Icons.table_chart,
            destination: const DriftScreen(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Part 3: Architecture',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(
            context,
            title: 'Offline-First Demo',
            subtitle: 'Repository caching, Syncing, Cache-first strategy.',
            icon: Icons.wifi_off,
            destination: const OfflineFirstScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destination,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
