// =============================================================================
// real_world_demo_screen.dart
// =============================================================================
// PURPOSE: A unified "Real-World Integration" demo showing all 6 local storage
// strategies working together inside a single simulated e-commerce app.
//
// Each tab simulates ONE feature of a real app, using the correct DB for it:
//   Tab 1 — Login          → flutter_secure_storage  (JWT token)
//   Tab 2 — Settings       → SharedPreferences        (theme/language flags)
//   Tab 3 — Cart           → Hive                     (offline product cache)
//   Tab 4 — News           → Isar                     (indexed full-text search)
//   Tab 5 — Orders         → SQLite (sqflite)          (relational schema)
//   Tab 6 — Tasks          → Drift                    (reactive type-safe SQL)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/hive_product.dart';
import '../models/isar_product.dart';
import '../data/isar/isar_service.dart';
import '../data/drift/drift_database.dart';

// =============================================================================
// ENTRY POINT WIDGET
// =============================================================================
class RealWorldDemoScreen extends StatelessWidget {
  const RealWorldDemoScreen({super.key});

  static const _tabs = [
    Tab(icon: Icon(Icons.lock_outline, size: 20), text: 'Login'),
    Tab(icon: Icon(Icons.settings_outlined, size: 20), text: 'Settings'),
    Tab(icon: Icon(Icons.shopping_cart_outlined, size: 20), text: 'Cart'),
    Tab(icon: Icon(Icons.newspaper_outlined, size: 20), text: 'News'),
    Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Orders'),
    Tab(icon: Icon(Icons.task_alt_outlined, size: 20), text: 'Tasks'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real-World Demo'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            _LoginTab(),       // Tab 1 – SecureStorage
            _SettingsTab(),    // Tab 2 – SharedPreferences
            _CartTab(),        // Tab 3 – Hive
            _NewsTab(),        // Tab 4 – Isar
            _OrdersTab(),      // Tab 5 – SQLite
            _TasksTab(),       // Tab 6 – Drift
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED HELPERS
// =============================================================================

/// Reusable section banner shown at the top of every tab.
/// It clearly shows WHICH storage technology this tab uses and WHY.
class _TabBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String storage;
  final String why;

  const _TabBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.storage,
    required this.why,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: cs.onSurface)),
                const SizedBox(height: 2),
                Text('Storage: $storage',
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text(why,
                    style:
                        TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple info row used inside result cards.
Widget _infoRow(String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
        Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
      ],
    ),
  );
}

// =============================================================================
// TAB 1 — LOGIN  (flutter_secure_storage)
// =============================================================================
// REAL-WORLD SCENARIO: After the user logs in, the API returns a JWT token.
// We MUST store it in Secure Storage (hardware-encrypted), NOT SharedPreferences.
// On app restart, we read the token and decide if the user is still logged in.
// =============================================================================
class _LoginTab extends StatefulWidget {
  const _LoginTab();
  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  // Step 1: Create a SecureStorage instance.
  // Under the hood this uses Android Keystore / iOS Keychain.
  final _storage = const FlutterSecureStorage();

  final _emailCtrl = TextEditingController(text: 'user@shopapp.com');
  final _passCtrl = TextEditingController(text: 'secret123');

  String? _storedToken;
  bool _isLoggedIn = false;
  bool _loading = false;
  String _log = '';

  static const _tokenKey = 'demo_jwt_token';

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  // On startup, read the token. If present → user is already authenticated.
  Future<void> _checkExistingToken() async {
    final token = await _storage.read(key: _tokenKey);
    setState(() {
      _storedToken = token;
      _isLoggedIn = token != null;
      _log = token != null
          ? '✅ Existing session restored from Secure Storage.'
          : '📭 No saved session. Please log in.';
    });
  }

  // Simulate login: generate a fake JWT and persist it securely.
  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    final fakeJwt =
        'eyJ.${_emailCtrl.text.hashCode.abs()}.${DateTime.now().millisecondsSinceEpoch}';

    // Step 2: Write the token to secure storage.
    await _storage.write(key: _tokenKey, value: fakeJwt);

    setState(() {
      _storedToken = fakeJwt;
      _isLoggedIn = true;
      _loading = false;
      _log = '🔐 JWT written to Secure Storage (AES-256 / Keychain).';
    });
  }

  // Step 3: Delete the token on logout.
  Future<void> _logout() async {
    await _storage.delete(key: _tokenKey);
    setState(() {
      _storedToken = null;
      _isLoggedIn = false;
      _log = '🗑 Token deleted from Secure Storage.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const _TabBanner(
            icon: Icons.lock,
            color: color,
            title: 'Login — JWT Token',
            storage: 'flutter_secure_storage',
            why:
                'Hardware AES-256. NEVER store tokens in SharedPrefs on rooted devices.',
          ),

          // Login Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Simulate Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: cs.onSurface)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isLoggedIn || _loading ? null : _login,
                            icon: _loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.login),
                            label: const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _isLoggedIn ? _logout : null,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Status Card
          if (_storedToken != null || _log.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: (_isLoggedIn ? Colors.green : Colors.red)
                    .withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: (_isLoggedIn ? Colors.green : Colors.red)
                            .withValues(alpha: 0.4))),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoggedIn ? '✅ Authenticated' : '❌ Not Logged In',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isLoggedIn ? Colors.green : Colors.red),
                      ),
                      const SizedBox(height: 6),
                      if (_storedToken != null)
                        _infoRow('Token',
                            '${_storedToken!.substring(0, 20)}...', color),
                      _infoRow('Log', _log, cs.primary),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Educational tip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text(
                '⚠️ SECURITY RULE\n'
                'JWT tokens stored in SharedPreferences are readable by any app '
                'on a rooted Android device. Secure Storage encrypts with the '
                'hardware-backed Android Keystore (API 23+) / iOS Keychain — '
                'keys NEVER leave the secure enclave.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 2 — SETTINGS  (SharedPreferences)
// =============================================================================
// REAL-WORLD SCENARIO: Store user UI preferences that persist across restarts.
// SharedPreferences is ideal for small, non-sensitive key-value data like
// theme mode, language selection, notification flags, and onboarding status.
// =============================================================================

// (Tab 2 class body below — Tab 3 and Tab 4 appended after Tab 2 closing brace)
class _SettingsTab extends StatefulWidget {
  const _SettingsTab();
  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  SharedPreferences? _prefs;
  bool _isDark = false;
  String _language = 'English';
  bool _notifications = true;
  bool _hasSeenOnboarding = false;
  bool _loaded = false;
  String _log = '';

  static const _languages = ['English', 'Hindi', 'Spanish', 'French'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Step 1: Call getInstance() once — loads the entire preference file into RAM.
  // After this, ALL reads are SYNCHRONOUS (no await needed).
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = _prefs!.getBool('isDark') ?? false;
      _language = _prefs!.getString('language') ?? 'English';
      _notifications = _prefs!.getBool('notifications') ?? true;
      _hasSeenOnboarding = _prefs!.getBool('hasSeenOnboarding') ?? false;
      _loaded = true;
      _log = '📂 Preferences loaded from disk into RAM.';
    });
  }

  // Step 2: Write values with typed setters. Writes are async (persist to disk).
  Future<void> _save() async {
    await _prefs!.setBool('isDark', _isDark);
    await _prefs!.setString('language', _language);
    await _prefs!.setBool('notifications', _notifications);
    await _prefs!.setBool('hasSeenOnboarding', _hasSeenOnboarding);
    setState(() => _log = '💾 All settings saved to SharedPreferences.');
  }

  Future<void> _clear() async {
    await _prefs!.clear();
    setState(() {
      _isDark = false;
      _language = 'English';
      _notifications = true;
      _hasSeenOnboarding = false;
      _log = '🗑 All SharedPreferences cleared.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.blue;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const _TabBanner(
            icon: Icons.settings,
            color: color,
            title: 'App Settings',
            storage: 'SharedPreferences',
            why: 'Light key-value store. Best for flags, theme, language.',
          ),

          if (!_loaded)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                          'Key: isDark  →  setBool / getBool',
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: cs.primary)),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: _isDark,
                      onChanged: (v) => setState(() => _isDark = v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: const Text('Language'),
                      subtitle: Text(
                          'Key: language  →  setString / getString',
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: cs.primary)),
                      trailing: DropdownButton<String>(
                        value: _language,
                        underline: const SizedBox(),
                        items: _languages
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _language = v ?? _language),
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: Text(
                          'Key: notifications  →  setBool',
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: cs.primary)),
                      secondary:
                          const Icon(Icons.notifications_none_outlined),
                      value: _notifications,
                      onChanged: (v) =>
                          setState(() => _notifications = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Has Seen Onboarding'),
                      subtitle: Text(
                          'Key: hasSeenOnboarding  →  setBool',
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: cs.primary)),
                      secondary: const Icon(Icons.tour_outlined),
                      value: _hasSeenOnboarding,
                      onChanged: (v) =>
                          setState(() => _hasSeenOnboarding = v),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Settings'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _clear,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_log.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withValues(alpha: 0.35))),
                child: Text(_log,
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 3 — CART  (Hive)
// =============================================================================
// REAL-WORLD SCENARIO: An e-commerce shopping cart that works offline.
// When a user adds items with no internet, the cart persists in Hive.
// On next launch, the cart is instantly restored from Hive's RAM-cache.
// Hive is perfect here: fast synchronous reads, pure Dart, no SQL needed.
// =============================================================================
class _CartTab extends StatefulWidget {
  const _CartTab();
  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  Box<HiveProduct>? _box;
  List<HiveProduct> _cartItems = [];
  bool _ready = false;
  String _log = '';

  static const _boxName = 'demoCartBox';

  // Sample catalogue items the user can add to cart
  final _catalogue = [
    HiveProduct(id: 'p1', name: 'Wireless Headphones', price: 2499.0),
    HiveProduct(id: 'p2', name: 'Mechanical Keyboard', price: 3999.0),
    HiveProduct(id: 'p3', name: 'USB-C Hub', price: 1299.0),
    HiveProduct(id: 'p4', name: 'Laptop Stand', price: 899.0),
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  // Step 1: Open (or reuse) a named Hive Box.
  // If the box was opened by HiveScreen earlier, Hive reuses the same instance.
  Future<void> _initHive() async {
    // Register adapter only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveProductAdapter());
    }
    _box = await Hive.openBox<HiveProduct>(_boxName);
    _refresh();
  }

  // Step 2: Read — synchronous because data is already in RAM after openBox().
  void _refresh() {
    setState(() {
      _cartItems = _box?.values.toList() ?? [];
      _ready = true;
    });
  }

  // Step 3: Write using put(key, value) — key is the product ID.
  Future<void> _addToCart(HiveProduct product) async {
    await _box!.put(product.id, product);
    setState(() => _log = '📦 put("${product.id}", ...) → ${product.name} added');
    _refresh();
  }

  // Step 4: Delete a specific key from the box.
  Future<void> _removeFromCart(String id) async {
    await _box!.delete(id);
    setState(() => _log = '🗑 delete("$id") executed.');
    _refresh();
  }

  // Step 5: Clear the entire box.
  Future<void> _clearCart() async {
    await _box!.clear();
    setState(() => _log = '🧹 Box cleared. All cart items removed.');
    _refresh();
  }

  double get _total =>
      _cartItems.fold(0.0, (sum, p) => sum + p.price);

  @override
  void dispose() {
    // Don't close box here — it's shared across the app session.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.orange;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const _TabBanner(
            icon: Icons.shopping_cart,
            color: color,
            title: 'Shopping Cart — Offline Persistent',
            storage: 'Hive (NoSQL Box)',
            why: 'Reads are synchronous (RAM). Perfect for offline cart caching.',
          ),

          // Catalogue — tap to add
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tap product to add to cart:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                ..._catalogue.map((p) {
                  final inCart =
                      _cartItems.any((c) => c.id == p.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: inCart
                            ? BorderSide(
                                color: color.withValues(alpha: 0.6))
                            : BorderSide.none),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: color, size: 18)),
                      title: Text(p.name,
                          style: const TextStyle(fontSize: 14)),
                      subtitle: Text('₹${p.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600)),
                      trailing: inCart
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: color),
                              onPressed: () => _removeFromCart(p.id),
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _addToCart(p),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Cart summary
          if (!_ready)
            const CircularProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: color.withValues(alpha: 0.35))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cart: ${_cartItems.length} item(s)',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        if (_log.isNotEmpty)
                          Text(_log,
                              style: const TextStyle(
                                  fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total',
                            style:
                                TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                        Text('₹${_total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cartItems.isEmpty ? null : _clearCart,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Cart (box.clear())'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 4 — NEWS  (Isar)
// =============================================================================
// REAL-WORLD SCENARIO: A news feed app caches articles locally in Isar.
// Isar's indexed queries allow instant full-text prefix search over thousands
// of articles without hitting the network — exactly like offline search in
// apps like Pocket, Feedly, or Flipboard.
// =============================================================================
class _NewsTab extends StatefulWidget {
  const _NewsTab();
  @override
  State<_NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<_NewsTab> {
  final _isarService = IsarService();
  final _searchCtrl = TextEditingController();

  List<IsarProduct> _articles = [];
  bool _ready = false;
  String _log = '';

  // Sample articles to seed
  final _seed = [
    ('Flutter 3.22 Released', 8.5),
    ('Dart 3 Features Deep Dive', 7.8),
    ('Firebase vs Supabase', 9.2),
    ('Isar vs Hive Performance', 6.9),
    ('Clean Architecture in Flutter', 9.5),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isar = await _isarService.db;
    final all = await isar.isarProducts.where().findAll();
    setState(() {
      _articles = all;
      _ready = true;
      _log = '✅ Loaded ${all.length} cached articles from Isar.';
    });
  }

  // Seed sample articles into Isar using ACID write transaction.
  Future<void> _seed_() async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      for (final s in _seed) {
        final a = IsarProduct()
          ..name = s.$1
          ..price = s.$2; // price field reused as "rating" for demo
        await isar.isarProducts.put(a);
      }
    });
    setState(() => _log = '📥 ${_seed.length} articles seeded via writeTxn().');
    _load();
  }

  // Step: Indexed prefix search — blazing fast even over millions of records.
  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      _load();
      return;
    }
    final results = await _isarService.searchProducts(q.trim());
    setState(() {
      _articles = results;
      _log = '🔍 nameStartsWith("$q") → ${results.length} result(s).';
    });
  }

  Future<void> _delete(IsarProduct a) async {
    await _isarService.deleteProduct(a.id);
    setState(() => _log = '🗑 Article ID=${a.id} deleted via writeTxn().');
    _load();
  }

  Future<void> _clearAll() async {
    await _isarService.clearAll();
    setState(() => _log = '🧹 All articles cleared from Isar collection.');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.deepOrange;

    return Column(
      children: [
        const _TabBanner(
          icon: Icons.newspaper,
          color: color,
          title: 'News Feed — Offline Search',
          storage: 'Isar (Indexed NoSQL)',
          why: 'Indexed prefix search over huge local datasets. Reactive streams.',
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search articles (nameStartsWith)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _load();
                      })
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
        ),

        const SizedBox(height: 8),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _seed_,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Seed Articles'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _articles.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Log line
        if (_log.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3))),
              child: Text(_log,
                  style: const TextStyle(
                      fontSize: 11, fontFamily: 'monospace')),
            ),
          ),

        // Article list
        Expanded(
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : _articles.isEmpty
                  ? Center(
                      child: Text('No articles cached.',
                          style: TextStyle(color: cs.onSurfaceVariant)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _articles.length,
                      itemBuilder: (_, i) {
                        final a = _articles[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  color.withValues(alpha: 0.12),
                              child: Text(
                                  a.price.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: color,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(a.name,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text('ID: ${a.id}',
                                style: const TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _delete(a),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 5 — ORDERS  (SQLite via sqflite)
// =============================================================================
// REAL-WORLD SCENARIO: An order history screen backed by a relational schema.
// SQLite shines when data has clear relationships (Users → Orders → Items)
// and requires complex WHERE, ORDER BY, or aggregate queries (SUM, COUNT).
// =============================================================================
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  Database? _db;
  List<Map<String, dynamic>> _orders = [];
  bool _ready = false;
  String _log = '';

  // Sample order statuses for demo
  final _statuses = ['Placed', 'Shipped', 'Delivered', 'Cancelled'];
  int _statusIdx = 0;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  // Step 1: Open the database and create the orders table.
  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'demo_orders.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        // Step 2: CREATE TABLE with a relational schema.
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product TEXT NOT NULL,
            amount REAL NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    await _loadOrders();
  }

  // Step 3: SELECT * with ORDER BY to show most recent orders first.
  Future<void> _loadOrders() async {
    final rows = await _db!
        .rawQuery('SELECT * FROM orders ORDER BY id DESC LIMIT 20');
    setState(() {
      _orders = rows;
      _ready = true;
      _log = '📋 SELECT * FROM orders ORDER BY id DESC → ${rows.length} rows';
    });
  }

  // Sample products for demo orders
  final _products = ['MacBook Pro', 'iPhone 15', 'AirPods Pro', 'iPad Air'];
  int _prodIdx = 0;

  // Step 4: INSERT a new order using parameterized query (SQL-injection safe).
  Future<void> _placeOrder() async {
    final product = _products[_prodIdx % _products.length];
    final amount = 999.0 + (_prodIdx * 500.0);
    final status = _statuses[_statusIdx % _statuses.length];
    final createdAt = DateTime.now().toIso8601String();

    await _db!.insert('orders', {
      'product': product,
      'amount': amount,
      'status': status,
      'created_at': createdAt,
    });

    setState(() {
      _log =
          '✅ INSERT INTO orders VALUES ("$product", $amount, "$status")';
      _prodIdx++;
      _statusIdx++;
    });
    await _loadOrders();
  }

  // Step 5: DELETE with a WHERE clause.
  Future<void> _deleteOrder(int id) async {
    await _db!.delete('orders', where: 'id = ?', whereArgs: [id]);
    setState(() => _log = '🗑 DELETE FROM orders WHERE id = $id');
    await _loadOrders();
  }

  // Step 6: DROP & recreate — destroy the entire database.
  Future<void> _clearAll() async {
    await _db!.execute('DELETE FROM orders');
    setState(() => _log = '🧹 DELETE FROM orders (all rows removed)');
    await _loadOrders();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Delivered' => Colors.green,
      'Shipped' => Colors.blue,
      'Cancelled' => Colors.red,
      _ => Colors.orange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.teal;

    return Column(
      children: [
        const _TabBanner(
          icon: Icons.receipt_long,
          color: color,
          title: 'Order History — Relational Schema',
          storage: 'SQLite (sqflite)',
          why: 'Raw SQL: CREATE TABLE, INSERT, SELECT, DELETE with WHERE.',
        ),

        // Place order + clear buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _ready ? _placeOrder : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Place Order'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _orders.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // SQL log
        if (_log.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3))),
              child: Text(_log,
                  style: const TextStyle(
                      fontSize: 11, fontFamily: 'monospace')),
            ),
          ),

        // Orders list
        Expanded(
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Text('No orders yet. Tap "Place Order".',
                          style: TextStyle(color: cs.onSurfaceVariant)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        final sc = _statusColor(o['status'] as String);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  sc.withValues(alpha: 0.12),
                              child: Text('#${o['id']}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: sc,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(o['product'] as String,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: sc.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(6)),
                                  child: Text(o['status'] as String,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: sc,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                    '₹${(o['amount'] as double).toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20),
                              onPressed: () =>
                                  _deleteOrder(o['id'] as int),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 6 — TASKS  (Drift)
// =============================================================================
// REAL-WORLD SCENARIO: A task manager with reactive UI.
// Drift's watchAll() stream means the UI updates automatically the moment
// any task is added or removed — no manual setState() needed.
// This is the production-grade pattern for budget apps, todo managers, etc.
// =============================================================================
class _TasksTab extends StatefulWidget {
  const _TasksTab();
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  // Step 1: Instantiate the generated AppDatabase.
  // Drift uses LazyDatabase, so the file is only opened on first query.
  late final AppDatabase _db;
  final _titleCtrl = TextEditingController();
  String _log = '';
  int _taskCount = 1;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _log = '🌊 watchAllProducts() stream is now active. UI auto-updates.';
  }

  @override
  void dispose() {
    _db.close();
    _titleCtrl.dispose();
    super.dispose();
  }

  // Step 2: Insert a task using the type-safe insertOrUpdateProduct().
  // The Dart compiler verifies column names — no runtime SQL errors!
  Future<void> _addTask() async {
    final name = _titleCtrl.text.trim();
    if (name.isEmpty) return;
    final task = DriftProduct(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      price: _taskCount.toDouble(), // price field = task priority for demo
    );
    await _db.insertOrUpdateProduct(task);
    setState(() {
      _log =
          '✅ into(driftProducts).insert(DriftProduct(...)) executed.';
      _taskCount++;
    });
    _titleCtrl.clear();
  }

  // Step 3: Delete using a type-safe WHERE clause (t.id.equals(id)).
  Future<void> _deleteTask(String id) async {
    await _db.deleteProduct(id);
    setState(() => _log = '🗑 (delete..where((t) => t.id.equals("$id"))).go()');
  }

  Future<void> _clearAll() async {
    await _db.clearProducts();
    setState(() => _log = '🧹 delete(driftProducts).go() — all rows removed.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Colors.indigo;

    return Column(
      children: [
        const _TabBanner(
          icon: Icons.task_alt,
          color: color,
          title: 'Task Manager — Reactive SQL',
          storage: 'Drift (Type-Safe SQLite)',
          why:
              'watchAll() stream auto-pushes changes to UI. No manual setState().',
        ),

        // Add task input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'New task name...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addTask,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // SQL log
        if (_log.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: color.withValues(alpha: 0.3))),
              child: Text(_log,
                  style: const TextStyle(
                      fontSize: 11, fontFamily: 'monospace')),
            ),
          ),

        // Step 4: StreamBuilder reacts to Drift's watchAllProducts() stream.
        // Every insert/delete automatically triggers a new emission → UI rebuilds.
        Expanded(
          child: StreamBuilder<List<DriftProduct>>(
            stream: _db.watchAllProducts(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = snap.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checklist_outlined,
                          size: 48,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text('No tasks yet. Add one above.',
                          style:
                              TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  // Clear all button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tasks.length} task(s)',
                            style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500)),
                        TextButton.icon(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) {
                        final t = tasks[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  color.withValues(alpha: 0.12),
                              child: Text('#${t.price.toInt()}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(t.name,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text('id: ${t.id}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace')),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_outlined,
                                  size: 22),
                              onPressed: () => _deleteTask(t.id),
                              tooltip: 'Mark done (delete)',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
