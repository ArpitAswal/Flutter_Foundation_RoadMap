import 'package:flutter/material.dart';
import '../viewmodels/http_viewmodel.dart';

// =============================================================================
// 📱 HTTP Demo Screen — Full CRUD with the standard `http` package
// =============================================================================

class HttpDemoScreen extends StatefulWidget {
  const HttpDemoScreen({super.key});

  @override
  State<HttpDemoScreen> createState() => _HttpDemoScreenState();
}

class _HttpDemoScreenState extends State<HttpDemoScreen>
    with SingleTickerProviderStateMixin {
  late final HttpViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = HttpViewModel();
    _tabController = TabController(length: 5, vsync: this);
    // Auto-load products when screen opens
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
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GetListTab(viewModel: _viewModel),
          _GetByIdTab(viewModel: _viewModel),
          _PostTab(viewModel: _viewModel),
          _PutTab(viewModel: _viewModel),
          _DeleteTab(viewModel: _viewModel),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      foregroundColor: Colors.white,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HTTP Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Manual URI, Manual jsonDecode, No Middleware', style: TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        indicatorColor: const Color(0xFF4CAF50),
        tabs: const [
          Tab(child: _MethodBadge('GET', '/ all', Color(0xFF4CAF50))),
          Tab(child: _MethodBadge('GET', '/{id}', Color(0xFF4CAF50))),
          Tab(child: _MethodBadge('POST', '/add', Color(0xFF2196F3))),
          Tab(child: _MethodBadge('PUT', '/{id}', Color(0xFFFF9800))),
          Tab(child: _MethodBadge('DELETE', '/{id}', Color(0xFFF44336))),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1: GET ALL
// =============================================================================
class _GetListTab extends StatelessWidget {
  final HttpViewModel viewModel;
  const _GetListTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            _ConceptBanner('http.get(Uri.parse(url))', 'Manual URI parsing • Manual jsonDecode • 200 status check', Colors.green),
            Expanded(
              child: viewModel.isLoadingList
                  ? const _LoadingIndicator('Fetching products via HTTP...')
                  : viewModel.listError != null
                      ? _ErrorDisplay(viewModel.listError!)
                      : _ProductList(products: viewModel.products),
            ),
            _ActionRow(onPressed: viewModel.fetchProducts, label: 'GET /products', color: Colors.green),
          ],
        );
      },
    );
  }
}

// =============================================================================
// TAB 2: GET BY ID
// =============================================================================
class _GetByIdTab extends StatelessWidget {
  final HttpViewModel viewModel;
  const _GetByIdTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: '1');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            _ConceptBanner('http.get(Uri.parse(\'/products/\$id\'))', 'Fetch a single resource by its primary key', Colors.green),
            _InputRow(controller: controller, hint: 'Product ID (e.g. 5)', keyboardType: TextInputType.number),
            Expanded(
              child: viewModel.isLoadingById
                  ? const _LoadingIndicator('Fetching product...')
                  : viewModel.byIdError != null
                      ? _ErrorDisplay(viewModel.byIdError!)
                      : viewModel.fetchedProduct != null
                          ? _ProductDetailCard(viewModel.fetchedProduct!)
                          : const _EmptyState('Enter an ID and press GET'),
            ),
            _ActionRow(
              onPressed: () => viewModel.fetchProductById(int.tryParse(controller.text) ?? 1),
              label: 'GET /products/{id}',
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// TAB 3: POST (CREATE)
// =============================================================================
class _PostTab extends StatelessWidget {
  final HttpViewModel viewModel;
  const _PostTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: 'My New Flutter Product');
    final priceController = TextEditingController(text: '99.99');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            _ConceptBanner("http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({...}))", 'Must manually set headers and encode body', Colors.blue),
            _InputRow(controller: titleController, hint: 'Product Title'),
            _InputRow(controller: priceController, hint: 'Price', keyboardType: TextInputType.number),
            Expanded(
              child: viewModel.isCreating
                  ? const _LoadingIndicator('Creating product...')
                  : viewModel.createError != null
                      ? _ErrorDisplay(viewModel.createError!)
                      : viewModel.createdProduct != null
                          ? _SuccessCard('Product Created!', viewModel.createdProduct!)
                          : const _EmptyState('Fill in the form and press POST'),
            ),
            _ActionRow(
              onPressed: () => viewModel.createProduct(
                titleController.text,
                double.tryParse(priceController.text) ?? 0,
              ),
              label: 'POST /products/add',
              color: Colors.blue,
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// TAB 4: PUT (UPDATE)
// =============================================================================
class _PutTab extends StatelessWidget {
  final HttpViewModel viewModel;
  const _PutTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController(text: '1');
    final titleController = TextEditingController(text: 'Updated Product Name');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            _ConceptBanner('http.put(uri, body: jsonEncode({...}))', 'PUT replaces the entire resource. PATCH updates a subset.', Colors.orange),
            _InputRow(controller: idController, hint: 'Product ID', keyboardType: TextInputType.number),
            _InputRow(controller: titleController, hint: 'New Title'),
            Expanded(
              child: viewModel.isUpdating
                  ? const _LoadingIndicator('Updating product...')
                  : viewModel.updateError != null
                      ? _ErrorDisplay(viewModel.updateError!)
                      : viewModel.updatedProduct != null
                          ? _SuccessCard('Product Updated!', viewModel.updatedProduct!)
                          : const _EmptyState('Fill in the form and press PUT'),
            ),
            _ActionRow(
              onPressed: () => viewModel.updateProduct(
                int.tryParse(idController.text) ?? 1,
                titleController.text,
              ),
              label: 'PUT /products/{id}',
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// TAB 5: DELETE
// =============================================================================
class _DeleteTab extends StatelessWidget {
  final HttpViewModel viewModel;
  const _DeleteTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController(text: '1');
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            _ConceptBanner('http.delete(Uri.parse(\'/products/\$id\'))', 'Idempotent: deleting the same ID twice is safe', Colors.red),
            _InputRow(controller: idController, hint: 'Product ID to Delete', keyboardType: TextInputType.number),
            Expanded(
              child: viewModel.isDeleting
                  ? const _LoadingIndicator('Deleting product...')
                  : viewModel.deleteError != null
                      ? _ErrorDisplay(viewModel.deleteError!)
                      : viewModel.deleteSuccess == true
                          ? const _DeleteSuccessDisplay()
                          : const _EmptyState('Enter an ID and press DELETE'),
            ),
            _ActionRow(
              onPressed: () => viewModel.deleteProduct(int.tryParse(idController.text) ?? 1),
              label: 'DELETE /products/{id}',
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _MethodBadge extends StatelessWidget {
  final String method;
  final String path;
  final Color color;
  const _MethodBadge(this.method, this.path, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(method, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 4),
        Text(path, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _ConceptBanner extends StatelessWidget {
  final String code;
  final String label;
  final Color color;
  const _ConceptBanner(this.code, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code, style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _InputRow({required this.controller, required this.hint, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

class _ActionRow extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  const _ActionRow({required this.onPressed, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final String message;
  const _LoadingIndicator(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String message;
  const _ErrorDisplay(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFF85149), size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFF85149))),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Colors.white24, size: 40),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List products;
  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _EmptyState('No products found.');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, index) {
        final p = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(p.imageUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image, color: Colors.white24)),
          ),
          title: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          subtitle: Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
          trailing: Text('#${p.id}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        );
      },
    );
  }
}

class _ProductDetailCard extends StatelessWidget {
  final dynamic product;
  const _ProductDetailCard(this.product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF21262D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product #${product.id}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 8),
              Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
              const SizedBox(height: 8),
              Text(product.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String title;
  final dynamic product;
  const _SuccessCard(this.title, this.product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF21262D),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${product.id}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteSuccessDisplay extends StatelessWidget {
  const _DeleteSuccessDisplay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_forever, color: Color(0xFFF44336), size: 56),
          SizedBox(height: 16),
          Text('Product Deleted!', style: TextStyle(color: Color(0xFFF44336), fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Server confirmed isDeleted: true', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}
