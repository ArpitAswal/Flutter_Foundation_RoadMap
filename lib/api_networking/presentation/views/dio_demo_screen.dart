import 'package:flutter/material.dart';
import '../viewmodels/dio_viewmodel.dart';

class DioDemoScreen extends StatefulWidget {
  const DioDemoScreen({super.key});

  @override
  State<DioDemoScreen> createState() => _DioDemoScreenState();
}

class _DioDemoScreenState extends State<DioDemoScreen>
    with SingleTickerProviderStateMixin {
  late final DioViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = DioViewModel();
    _tabController = TabController(length: 6, vsync: this);
    _viewModel.fetchProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F2E),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dio Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Interceptors • Retry • Cancel • Debounce', style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          indicatorColor: Colors.orangeAccent,
          tabs: const [
            Tab(child: _MethodChip('GET', 'all', Color(0xFF4CAF50))),
            Tab(child: _MethodChip('GET', 'id', Color(0xFF4CAF50))),
            Tab(child: _MethodChip('POST', 'add', Color(0xFF2196F3))),
            Tab(child: _MethodChip('PUT', 'id', Color(0xFFFF9800))),
            Tab(child: _MethodChip('DELETE', 'id', Color(0xFFF44336))),
            Tab(child: _MethodChip('ADV', '✦', Color(0xFF9C27B0))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GetListTab(viewModel: _viewModel),
          _GetByIdTab(viewModel: _viewModel),
          _PostTab(viewModel: _viewModel),
          _PutTab(viewModel: _viewModel),
          _DeleteTab(viewModel: _viewModel),
          _AdvancedTab(viewModel: _viewModel),
        ],
      ),
    );
  }
}

// =============================================================================
// TABS
// =============================================================================

class _GetListTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _GetListTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(children: [
        _Banner("dio.get('/products', cancelToken: cancelToken)", 'Auth token auto-injected by Interceptor • Retry on failure', Colors.green),
        _AuthBadge(),
        Expanded(
          child: viewModel.isLoadingList
              ? const _LoadingMsg('Fetching via Dio...\nRetry logic active')
              : viewModel.listError != null
                  ? _Err(viewModel.listError!)
                  : _ProdList(viewModel.products),
        ),
        Row(children: [
          Expanded(child: _Btn('GET /products', Colors.green, viewModel.fetchProducts)),
          Expanded(child: _Btn('CANCEL', Colors.red.shade800, viewModel.cancelFetch)),
        ]),
      ]),
    );
  }
}

class _GetByIdTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _GetByIdTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: '3');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(children: [
        _Banner("dio.get('/products/\$id')", 'No jsonDecode needed — Dio auto-parses JSON', Colors.green),
        _Field(ctrl, 'Product ID', TextInputType.number),
        Expanded(
          child: viewModel.isLoadingById
              ? const _LoadingMsg('Fetching...')
              : viewModel.byIdError != null
                  ? _Err(viewModel.byIdError!)
                  : viewModel.fetchedProduct != null
                      ? _DetailCard(viewModel.fetchedProduct!)
                      : const _Hint('Enter ID and press GET'),
        ),
        _Btn('GET /products/{id}', Colors.green, () => viewModel.fetchProductById(int.tryParse(ctrl.text) ?? 1)),
      ]),
    );
  }
}

class _PostTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _PostTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Flutter Dio Product');
    final priceCtrl = TextEditingController(text: '49.99');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(children: [
        _Banner("dio.post('/products/add', data: {title, price})", 'Dio auto-serializes Map → JSON body. No headers needed!', Colors.blue),
        _Field(titleCtrl, 'Product Title'),
        _Field(priceCtrl, 'Price', TextInputType.number),
        Expanded(
          child: viewModel.isCreating
              ? const _LoadingMsg('Creating...')
              : viewModel.createError != null
                  ? _Err(viewModel.createError!)
                  : viewModel.createdProduct != null
                      ? _Success('Created!', viewModel.createdProduct!)
                      : const _Hint('Fill in and press POST'),
        ),
        _Btn('POST /products/add', Colors.blue, () => viewModel.createProduct(titleCtrl.text, double.tryParse(priceCtrl.text) ?? 0)),
      ]),
    );
  }
}

class _PutTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _PutTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController(text: '1');
    final titleCtrl = TextEditingController(text: 'Dio Updated Title');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(children: [
        _Banner("dio.put('/products/\$id', data: {'title': title})", 'Interceptor injects Authorization before every PUT request', Colors.orange),
        _Field(idCtrl, 'Product ID', TextInputType.number),
        _Field(titleCtrl, 'New Title'),
        Expanded(
          child: viewModel.isUpdating
              ? const _LoadingMsg('Updating...')
              : viewModel.updateError != null
                  ? _Err(viewModel.updateError!)
                  : viewModel.updatedProduct != null
                      ? _Success('Updated!', viewModel.updatedProduct!)
                      : const _Hint('Fill in and press PUT'),
        ),
        _Btn('PUT /products/{id}', Colors.orange, () => viewModel.updateProduct(int.tryParse(idCtrl.text) ?? 1, titleCtrl.text)),
      ]),
    );
  }
}

class _DeleteTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _DeleteTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController(text: '1');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(children: [
        _Banner("dio.delete('/products/\$id')", 'DELETE is idempotent — calling it multiple times is safe', Colors.red),
        _Field(idCtrl, 'Product ID to Delete', TextInputType.number),
        Expanded(
          child: viewModel.isDeleting
              ? const _LoadingMsg('Deleting...')
              : viewModel.deleteError != null
                  ? _Err(viewModel.deleteError!)
                  : viewModel.deleteSuccess == true
                      ? const _DelSuccess()
                      : const _Hint('Enter ID and press DELETE'),
        ),
        _Btn('DELETE /products/{id}', Colors.red, () => viewModel.deleteProduct(int.tryParse(idCtrl.text) ?? 1)),
      ]),
    );
  }
}

class _AdvancedTab extends StatelessWidget {
  final DioViewModel viewModel;
  const _AdvancedTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        _SectionHead('🔍 Debounced Search', 'Fires API call 500ms AFTER you stop typing', Colors.purple),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type a product name...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: viewModel.isSearching
                ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : const Icon(Icons.search, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF21262D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onChanged: viewModel.onSearchChanged,
        ),
        const SizedBox(height: 8),
        if (viewModel.searchResults.isNotEmpty) ...[
          Text('${viewModel.searchResults.length} results', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 6),
          ...viewModel.searchResults.take(5).map((p) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF21262D), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 12))),
              Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
            ]),
          )),
        ] else if (viewModel.searchQuery.isNotEmpty && !viewModel.isSearching)
          const Text('No results found.', style: TextStyle(color: Colors.white38)),

        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),

        _SectionHead('✕ Request Cancellation', 'Press FETCH then immediately CANCEL', Colors.orange),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Btn('FETCH', Colors.green.shade700, viewModel.fetchProducts)),
          const SizedBox(width: 8),
          Expanded(child: _Btn('CANCEL', Colors.red.shade700, viewModel.cancelFetch)),
        ]),
        if (viewModel.isLoadingList)
          const Padding(padding: EdgeInsets.all(8), child: Text('⏳ Request in-flight...', style: TextStyle(color: Colors.orangeAccent, fontSize: 12))),
        if (viewModel.listError != null && !viewModel.isLoadingList)
          Padding(padding: const EdgeInsets.all(8), child: Text(viewModel.listError!, style: const TextStyle(color: Color(0xFFF85149), fontSize: 12))),
      ]),
    );
  }
}

// =============================================================================
// SHARED PRIMITIVES
// =============================================================================

class _MethodChip extends StatelessWidget {
  final String method;
  final String sub;
  final Color color;
  const _MethodChip(this.method, this.sub, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(method, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 4),
      Text(sub, style: const TextStyle(fontSize: 10)),
    ]);
  }
}

class _AuthBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.35)),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shield, size: 12, color: Colors.purpleAccent),
        SizedBox(width: 6),
        Flexible(child: Text('Authorization: Bearer token  ← injected by Interceptor', style: TextStyle(color: Colors.purpleAccent, fontSize: 11))),
      ]),
    );
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;
  const _SectionHead(this.title, this.sub, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}

class _Banner extends StatelessWidget {
  final String code;
  final String label;
  final Color color;
  const _Banner(this.code, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(code, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType kb;
  const _Field(this.ctrl, this.hint, [this.kb = TextInputType.text]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: kb,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF21262D),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _Btn(this.label, this.color, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

class _LoadingMsg extends StatelessWidget {
  final String msg;
  const _LoadingMsg(this.msg);

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: Colors.orangeAccent),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]));
  }
}

class _Err extends StatelessWidget {
  final String msg;
  const _Err(this.msg);

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.warning_amber_rounded, color: Color(0xFFF85149), size: 40),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFF85149))),
    ])));
  }
}

class _Hint extends StatelessWidget {
  final String msg;
  const _Hint(this.msg);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(msg, style: const TextStyle(color: Colors.white38)));
  }
}

class _ProdList extends StatelessWidget {
  final List products;
  const _ProdList(this.products);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _Hint('No products loaded.');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, i) {
        final p = products[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(p.imageUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image, color: Colors.white24))),
          title: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          subtitle: Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
          trailing: Text('#${p.id}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final dynamic p;
  const _DetailCard(this.p);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF21262D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('#${p.id}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 6),
          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
          const SizedBox(height: 8),
          Text(p.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
      ),
    );
  }
}

class _Success extends StatelessWidget {
  final String title;
  final dynamic p;
  const _Success(this.title, this.p);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(color: const Color(0xFF21262D), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ID: ${p.id}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent)),
        ]))),
      ]),
    );
  }
}

class _DelSuccess extends StatelessWidget {
  const _DelSuccess();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.delete_forever, color: Color(0xFFF44336), size: 56),
      SizedBox(height: 12),
      Text('Deleted!', style: TextStyle(color: Color(0xFFF44336), fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 6),
      Text('isDeleted: true', style: TextStyle(color: Colors.white38)),
    ]));
  }
}
