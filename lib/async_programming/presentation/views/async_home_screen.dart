import 'package:flutter/material.dart';
import 'future_builder_screen.dart';
import 'stream_counter_screen.dart';
import 'parallel_async_screen.dart';
import 'advanced_async_screen.dart';

// =============================================================================
// 🏠 AsyncHomeScreen — Module Navigation Hub
// =============================================================================
//
// This screen serves as the entry point for the entire async_programming module.
// It lists all three assignment tasks as navigation cards so learners can
// explore each concept independently.
//
// DESIGN INTENT:
//   Each card shows: Title, brief description, and a difficulty/concept tag.
//   Tapping navigates to the corresponding demo screen using standard
//   Navigator.push (appropriate for learning modules; no GoRouter needed here).
// =============================================================================

/// The home/hub screen for the Async Programming learning module.
class AsyncHomeScreen extends StatelessWidget {
  const AsyncHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define the three demo entries. Each entry maps to one assignment task.
    final demos = [
      _DemoEntry(
        task: 'Task 1',
        title: 'FutureBuilder Demo',
        subtitle: 'Fetch data asynchronously. See loading, success, and error '
            'states with a retry button.',
        icon: Icons.cloud_download_rounded,
        color: colorScheme.primary,
        concepts: const ['Future', 'FutureBuilder', 'Error Handling', 'Retry'],
        destination: const FutureBuilderScreen(),
      ),
      _DemoEntry(
        task: 'Task 2',
        title: 'Live Stream Counter',
        subtitle: 'A real-time counter powered by a Dart Stream. Start, stop, '
            'and observe memory-safe disposal.',
        icon: Icons.stream_rounded,
        color: colorScheme.secondary,
        concepts: const ['Stream', 'StreamBuilder', 'Subscription', 'Disposal'],
        destination: const StreamCounterScreen(),
      ),
      _DemoEntry(
        task: 'Task 3',
        title: 'Parallel vs Sequential',
        subtitle: 'Compare Future.wait (parallel) against sequential awaits. '
            'See the real time difference.',
        icon: Icons.bolt_rounded,
        color: colorScheme.tertiary,
        concepts: const ['Future.wait', 'Parallel', 'Sequential', 'Stopwatch'],
        destination: const ParallelAsyncScreen(),
      ),
      _DemoEntry(
        task: 'Advanced',
        title: 'Completer & Isolates',
        subtitle: 'Manual Future control and heavy CPU task offloading to worker '
            'threads (Isolates).',
        icon: Icons.psychology_rounded,
        color: Colors.deepPurple,
        concepts: const ['Completer', 'Isolates', 'StreamController', 'compute()'],
        destination: const AdvancedAsyncScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Async Programming',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Futures · Streams · Event Loop',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Module Overview Card ────────────────────────────────────────────
          _ModuleOverviewCard(colorScheme: colorScheme, theme: theme),
          const SizedBox(height: 20),

          // ── Section Header ──────────────────────────────────────────────────
          Text(
            'ASSIGNMENTS',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withAlpha(128),
            ),
          ),
          const SizedBox(height: 12),

          // ── Demo Cards ──────────────────────────────────────────────────────
          ...demos.map((entry) => _DemoCard(entry: entry, theme: theme)),
        ],
      ),
    );
  }
}

// =============================================================================
// 🗂️ Data classes and private widgets
// =============================================================================

/// Data holder for each demo entry.
class _DemoEntry {
  final String task;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> concepts;
  final Widget destination;

  const _DemoEntry({
    required this.task,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.concepts,
    required this.destination,
  });
}

/// Overview card explaining what this module covers.
class _ModuleOverviewCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ModuleOverviewCard({
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded,
                  color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                'What You\'ll Learn',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            '⚡  Dart\'s single-threaded event loop model',
            '🔮  Future lifecycle: uncompleted → completed',
            '📺  Streams: continuous async data sequences',
            '🛡️  Memory-safe StreamSubscription disposal',
            '🚀  Parallel futures with Future.wait',
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withAlpha(204),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation card for a single demo.
class _DemoCard extends StatelessWidget {
  final _DemoEntry entry;
  final ThemeData theme;

  const _DemoCard({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => entry.destination),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon Badge ───────────────────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: entry.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(entry.icon, color: entry.color, size: 24),
                ),
                const SizedBox(width: 14),

                // ── Text Content ─────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: entry.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              entry.task,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: entry.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ── Concept Chips ──────────────────────────────────────
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: entry.concepts
                            .map(
                              (concept) => Chip(
                                label: Text(concept),
                                labelStyle: theme.textTheme.labelSmall?.copyWith(
                                  color: entry.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: entry.color.withAlpha(20),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // ── Chevron ──────────────────────────────────────────────────
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withAlpha(102),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
