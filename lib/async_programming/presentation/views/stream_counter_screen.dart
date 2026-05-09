import 'package:flutter/material.dart';
import '../viewmodels/stream_demo_viewmodel.dart';

// =============================================================================
// 📺 StreamCounterScreen — Task 2: Live Counter with StreamBuilder
// =============================================================================
//
// WHAT THIS SCREEN DEMONSTRATES:
//   1. StreamBuilder consuming a Stream<int> for real-time UI updates
//   2. Start/stop controls for stream lifecycle management
//   3. Memory-safe disposal via StreamSubscription in ViewModel.dispose()
//   4. Single-subscription vs broadcast stream explanation
//
// STREAMBUILDER INTERNALS:
//   StreamBuilder<T>(stream: myStream, builder: (context, snapshot) { ... })
//
//   snapshot.connectionState can be:
//     ConnectionState.none    → stream is null
//     ConnectionState.waiting → stream started, no values yet
//     ConnectionState.active  → stream is emitting values (snapshot.data updates)
//     ConnectionState.done    → stream closed/completed
//
//   Unlike FutureBuilder, StreamBuilder's state transitions through
//   waiting → active (many times) → done. Each `yield` in the stream
//   causes a `ConnectionState.active` snapshot with the new value.
//
// MEMORY LEAK DEMONSTRATION:
//   The ViewModel holds the StreamSubscription and cancels it in dispose().
//   If you pop this screen, the ViewModel is disposed, subscription is cancelled,
//   and the stream stops consuming resources. NO LEAK.
// =============================================================================

/// Task 2: Live stream counter with start/stop and StreamBuilder.
class StreamCounterScreen extends StatefulWidget {
  const StreamCounterScreen({super.key});

  @override
  State<StreamCounterScreen> createState() => _StreamCounterScreenState();
}

class _StreamCounterScreenState extends State<StreamCounterScreen>
    with SingleTickerProviderStateMixin {
  late final StreamDemoViewModel _viewModel;

  /// Animation controller for the counter display (pulse effect on each tick).
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = StreamDemoViewModel(maxCount: 10);

    // Pulse animation triggered every time the counter ticks
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    // The ViewModel cancels the StreamSubscription here — no leak
    _viewModel.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTick() {
    // Play pulse animation on each new stream value
    _pulseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Stream Counter',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Stream + StreamBuilder',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Concept Explanation ────────────────────────────────────────
            _ConceptCard(
              theme: theme,
              colorScheme: colorScheme,
              icon: Icons.stream_rounded,
              title: 'Stream vs Future',
              points: const [
                'Future → emits ONE value, then done',
                'Stream → emits MULTIPLE values over time',
                'StreamBuilder rebuilds on each new value',
                'ConnectionState: none → waiting → active → done',
                '⚠️ Always cancel StreamSubscription in dispose()',
              ],
            ),
            const SizedBox(height: 20),

            // ── Counter Display Area ───────────────────────────────────────
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return _CounterDisplayCard(
                  viewModel: _viewModel,
                  theme: theme,
                  colorScheme: colorScheme,
                  pulseAnimation: _pulseAnimation,
                  onTick: _onTick,
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Controls ────────────────────────────────────────────────────
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return _ControlButtons(
                  viewModel: _viewModel,
                  colorScheme: colorScheme,
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Memory Leak Info ────────────────────────────────────────────
            _MemoryLeakInfoCard(theme: theme, colorScheme: colorScheme),
            const SizedBox(height: 24),

            // ── Broadcast vs Single Subscription ───────────────────────────
            _BroadcastCard(theme: theme, colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🧩 Private sub-widgets
// =============================================================================

/// The main counter display with StreamBuilder integration.
class _CounterDisplayCard extends StatelessWidget {
  final StreamDemoViewModel viewModel;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Animation<double> pulseAnimation;
  final VoidCallback onTick;

  const _CounterDisplayCard({
    required this.viewModel,
    required this.theme,
    required this.colorScheme,
    required this.pulseAnimation,
    required this.onTick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // StreamBuilder is the reactive core of this screen.
          // It rebuilds whenever the stream emits a new value.
          StreamBuilder<int>(
            // Passing the stream from ViewModel. null when not started.
            stream: viewModel.activeStream,
            builder: (context, snapshot) {
              // Determine what to display based on connection state
              final connectionLabel = switch (snapshot.connectionState) {
                ConnectionState.none => '● none',
                ConnectionState.waiting => '⏳ waiting',
                ConnectionState.active => '✅ active',
                ConnectionState.done => '✔️ done',
              };

              // Trigger pulse animation when active and data is received
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) => onTick());
              }

              return Column(
                children: [
                  // Connection state badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(179),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ConnectionState: $connectionLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated counter number
                  ScaleTransition(
                    scale: pulseAnimation,
                    child: Text(
                      _getDisplayValue(snapshot),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusLabel(snapshot, viewModel),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer.withAlpha(179),
                    ),
                  ),
                ],
              );
            },
          ),

          // Progress bar showing how far through the count we are
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: viewModel.maxCount > 0
                  ? viewModel.currentCount / viewModel.maxCount
                  : 0,
              minHeight: 6,
              backgroundColor: colorScheme.surface.withAlpha(77),
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.currentCount} / ${viewModel.maxCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayValue(AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) return '${snapshot.data}';
    if (snapshot.connectionState == ConnectionState.done) {
      return '✓';
    }
    return '--';
  }

  String _getStatusLabel(
      AsyncSnapshot<int> snapshot, StreamDemoViewModel vm) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return 'Stream started, waiting for first value…';
    }
    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
      return 'Receiving values every 1 second';
    }
    if (snapshot.connectionState == ConnectionState.done) {
      return 'Stream completed — reached max count of ${vm.maxCount}';
    }
    if (!vm.isRunning && vm.currentCount == 0) {
      return 'Tap START to begin the stream';
    }
    return 'Stream stopped at ${vm.currentCount}';
  }
}

/// Start / Stop / Reset control buttons.
class _ControlButtons extends StatelessWidget {
  final StreamDemoViewModel viewModel;
  final ColorScheme colorScheme;

  const _ControlButtons({
    required this.viewModel,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // START button — disabled when already running
        Expanded(
          child: FilledButton.icon(
            onPressed: viewModel.isRunning ? null : viewModel.startCounter,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('START'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // STOP button — disabled when not running
        Expanded(
          child: FilledButton.icon(
            onPressed: viewModel.isRunning ? viewModel.stopCounter : null,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('STOP'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // RESET button — always available
        OutlinedButton.icon(
          onPressed: viewModel.reset,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('RESET'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}

/// Informational card about memory leak prevention.
class _MemoryLeakInfoCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _MemoryLeakInfoCard({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Memory Leak Prevention',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CodeBlock(
            theme: theme,
            code: '// ❌ DANGEROUS — subscription never cancelled\n'
                'stream.listen((v) { setState(() {}); });\n\n'
                '// ✅ CORRECT — ViewModel holds + cancels subscription\n'
                'late StreamSubscription _sub;\n'
                '_sub = stream.listen((v) { ... });\n\n'
                '@override\n'
                'void dispose() {\n'
                '  _sub.cancel(); // ← This prevents the leak\n'
                '  super.dispose();\n'
                '}',
          ),
        ],
      ),
    );
  }
}

/// Informational card about broadcast streams.
class _BroadcastCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _BroadcastCard({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_rounded,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Broadcast vs Single-Subscription',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CodeBlock(
            theme: theme,
            code: '// Single-subscription (default) — 1 listener only\n'
                'Stream<int> myStream = counterStream();\n\n'
                '// ❌ Second listener throws StateError:\n'
                '// myStream.listen(listenerA);\n'
                '// myStream.listen(listenerB); // CRASH\n\n'
                '// ✅ Broadcast — multiple listeners allowed:\n'
                'final broadcast = myStream.asBroadcastStream();\n'
                'broadcast.listen(listenerA);\n'
                'broadcast.listen(listenerB); // Works fine',
          ),
        ],
      ),
    );
  }
}

/// Monospaced code snippet display widget.
class _CodeBlock extends StatelessWidget {
  final ThemeData theme;
  final String code;

  const _CodeBlock({required this.theme, required this.code});

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        code,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: colorScheme.onSurface.withAlpha(204),
          height: 1.6,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Shared concept explanation card.
class _ConceptCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final List<String> points;

  const _ConceptCard({
    required this.theme,
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                p,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(179),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
