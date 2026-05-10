import 'package:flutter/material.dart';
import 'dio_demo_screen.dart';
import 'graphql_demo_screen.dart';
import 'http_demo_screen.dart';

// =============================================================================
// 🏠 API Networking — Home Screen
// =============================================================================

class NetworkingHomeScreen extends StatelessWidget {
  const NetworkingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Networking Architecture', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('HTTP • Dio • GraphQL', style: TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ArchitectureCard(),
          const SizedBox(height: 20),
          _DemoCard(
            index: '01',
            title: 'Standard HTTP Package',
            subtitle: 'GET • POST • PUT • DELETE',
            description: 'Manual URI parsing, manual jsonDecode, no interceptors. Great for learning the raw mechanics.',
            concepts: const ['Manual URI', 'jsonDecode()', 'Status checks', 'Full CRUD'],
            color: const Color(0xFF238636),
            icon: Icons.http,
            destination: const HttpDemoScreen(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            index: '02',
            title: 'Dio — Production Client',
            subtitle: 'CRUD + Interceptors + Retry + Cancel + Debounce',
            description: 'Enterprise-grade networking with middleware pipeline. Auto-JSON, auth injection, and lifecycle-safe cancellation.',
            concepts: const ['Interceptors', 'CancelToken', 'Retry', 'Debounce', 'DTO→Domain'],
            color: const Color(0xFFD29922),
            icon: Icons.rocket_launch,
            destination: const DioDemoScreen(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            index: '03',
            title: 'GraphQL',
            subtitle: 'Query + Mutation',
            description: 'Single endpoint, flexible schema. Request only the exact fields you need. Prevents overfetching.',
            concepts: const ['Single Endpoint', 'Query', 'Mutation', 'No Overfetch'],
            color: const Color(0xFFBF4BBB),
            icon: Icons.hub,
            destination: const GraphqlDemoScreen(),
          ),
          const SizedBox(height: 20),
          _LayerDiagram(),
        ],
      ),
    );
  }
}

class _ArchitectureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.architecture, color: Colors.blueAccent, size: 18),
            SizedBox(width: 8),
            Text('Production Architecture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          SizedBox(height: 10),
          Text(
            'UI → ViewModel → Repository → Data Source → Network',
            style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontFamily: 'monospace'),
          ),
          SizedBox(height: 8),
          Text(
            'Each layer is strictly isolated. The UI never sees raw JSON or DTOs. The Data Source never knows about the UI.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;
  final String description;
  final List<String> concepts;
  final Color color;
  final IconData icon;
  final Widget destination;

  const _DemoCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.concepts,
    required this.color,
    required this.icon,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(index, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                ]),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
              ])),
            ]),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: concepts.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.25))),
                child: Text(c, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const layers = [
      ('View', 'ListenableBuilder + TabBarView', Colors.blue),
      ('ViewModel', 'HttpViewModel / DioViewModel / GraphqlViewModel', Colors.green),
      ('Repository', 'NetworkingRepository (DTO → Domain mapping)', Colors.orange),
      ('Data Source', 'ProductRemoteDataSource / GraphqlRemoteDataSource', Colors.purple),
      ('Network', 'http.get() / dio.instance / GraphQLClient', Colors.pink),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Layer Diagram', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          ...layers.map((l) {
            final (name, detail, color) = l;
            return Column(children: [
              Row(children: [
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(name, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(detail, style: const TextStyle(color: Colors.white54, fontSize: 11))),
              ]),
              if (name != 'Network') const Padding(padding: EdgeInsets.only(left: 39, top: 3, bottom: 3), child: Text('↓', style: TextStyle(color: Colors.white24))),
            ]);
          }),
        ],
      ),
    );
  }
}
