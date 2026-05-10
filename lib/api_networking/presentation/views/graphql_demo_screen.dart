import 'package:flutter/material.dart';
import '../viewmodels/graphql_viewmodel.dart';

// =============================================================================
// 📱 GraphQL Demo Screen — Query + Mutation
// =============================================================================

class GraphqlDemoScreen extends StatefulWidget {
  const GraphqlDemoScreen({super.key});

  @override
  State<GraphqlDemoScreen> createState() => _GraphqlDemoScreenState();
}

class _GraphqlDemoScreenState extends State<GraphqlDemoScreen>
    with SingleTickerProviderStateMixin {
  late final GraphqlViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = GraphqlViewModel();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel.fetchCountries();
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
        backgroundColor: const Color(0xFF1A1035),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GraphQL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Single endpoint • No overfetching • Query & Mutation', style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          indicatorColor: Colors.pinkAccent,
          tabs: const [
            Tab(icon: Icon(Icons.search, size: 16), text: 'Query'),
            Tab(icon: Icon(Icons.edit, size: 16), text: 'Mutation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QueryTab(viewModel: _viewModel),
          _MutationTab(viewModel: _viewModel),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1: QUERY (READ)
// =============================================================================
class _QueryTab extends StatelessWidget {
  final GraphqlViewModel viewModel;
  const _QueryTab({required this.viewModel});

  static const _queryCode = '''query GetCountries {
  countries {
    code
    name
    emoji
    capital
  }
}''';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Architecture banner
            Container(
              width: double.infinity,
              color: Colors.pink.withValues(alpha: 0.08),
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GraphQL Query — Read Operation', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('Like GET in REST. Frontend requests ONLY the exact fields it needs.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            // GraphQL code preview
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.code, color: Colors.pinkAccent, size: 14),
                    SizedBox(width: 6),
                    Text('Query Document', style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 8),
                  Text(_queryCode, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  const Text('👆 Only code, name, emoji, capital returned. No over fetch.', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            // Results
            Expanded(
              child: viewModel.isLoadingCountries
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircularProgressIndicator(color: Colors.pinkAccent),
                      SizedBox(height: 12),
                      Text('Querying GraphQL API...', style: TextStyle(color: Colors.white54)),
                    ]))
                  : viewModel.countriesError != null
                      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.error_outline, color: Colors.pinkAccent, size: 40),
                          const SizedBox(height: 12),
                          Text(viewModel.countriesError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.pinkAccent)),
                        ])))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: viewModel.countries.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                          itemBuilder: (context, i) {
                            final c = viewModel.countries[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              leading: Text(c.emoji, style: const TextStyle(fontSize: 28)),
                              title: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                              subtitle: Text(c.capital.isEmpty ? 'No capital' : c.capital, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text(c.code, style: const TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: viewModel.fetchCountries,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Execute Query', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// TAB 2: MUTATION (WRITE)
// =============================================================================
class _MutationTab extends StatelessWidget {
  final GraphqlViewModel viewModel;
  const _MutationTab({required this.viewModel});

  static const _mutationCode = '''mutation AddProduct(
  \$title: String!
  \$price: Float!
) {
  addProduct(title: \$title, price: \$price) {
    id
    title
    price
  }
}''';

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'GraphQL Product');
    final priceCtrl = TextEditingController(text: '129.00');

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Architecture banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('GraphQL Mutation — Write Operation', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 2),
                Text('Like POST/PUT/DELETE in REST. One endpoint for all write operations.', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 12),
            // Mutation code preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.code, color: Colors.purpleAccent, size: 14),
                  SizedBox(width: 6),
                  Text('Mutation Document', style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Text(_mutationCode, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
              ]),
            ),
            const SizedBox(height: 16),
            // Form
            _GqlField(titleCtrl, 'Product Title (\$title)'),
            const SizedBox(height: 8),
            _GqlField(priceCtrl, 'Price (\$price)', TextInputType.number),
            const SizedBox(height: 16),
            // Result
            if (viewModel.isMutating)
              const Center(child: Column(children: [
                CircularProgressIndicator(color: Colors.purpleAccent),
                SizedBox(height: 12),
                Text('Executing mutation...', style: TextStyle(color: Colors.white54)),
              ]))
            else if (viewModel.mutationError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(viewModel.mutationError!, style: const TextStyle(color: Color(0xFFF85149))),
              )
            else if (viewModel.mutationSuccess && viewModel.mutationResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Mutation Successful!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  const Text('Response:', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('{ id: ${viewModel.mutationResult!.id}, name: "${viewModel.mutationResult!.name}", price: ${viewModel.mutationResult!.price} }',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace')),
                ]),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: viewModel.isMutating
                  ? null
                  : () => viewModel.createProduct(titleCtrl.text, double.tryParse(priceCtrl.text) ?? 0),
              icon: const Icon(Icons.send),
              label: const Text('Execute Mutation', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (viewModel.mutationSuccess) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: viewModel.resetMutation, child: const Text('Reset', style: TextStyle(color: Colors.white38))),
            ],
          ],
        );
      },
    );
  }
}

class _GqlField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType kb;
  const _GqlField(this.ctrl, this.hint, [this.kb = TextInputType.text]);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: kb,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
