import 'package:flutter/material.dart';
import '../viewmodels/parallel_demo_viewmodel.dart';

// =============================================================================
// ⚡ ParallelAsyncScreen — Task 3: Sequential vs Parallel Future Execution
// =============================================================================
//
// WHAT THIS SCREEN DEMONSTRATES:
//   1. Sequential execution: await A; await B; → ~3.5s total
//   2. Parallel execution:  Future.wait([A, B]) → ~2.0s total
//   3. Stopwatch-measured timing shown after each run
//   4. Side-by-side comparison panel once both results are available
//
// MVVM PATTERN:
//   All timing, async calls, and result storage live in ParallelDemoViewModel.
//   The View only renders state and dispatches user actions.
//
// KEY CONCEPTS TAUGHT:
//   - Future.wait([]) starts all futures simultaneously
//   - Sequential await forces serialization (B can't start until A finishes)
//   - The improvement is most dramatic when I/O operations are independent
// =============================================================================

/// Task 3: Side-by-side sequential vs parallel async comparison.
class ParallelAsyncScreen extends StatefulWidget {
  const ParallelAsyncScreen({super.key});

  @override
  State<ParallelAsyncScreen> createState() => _ParallelAsyncScreenState();
}

class _ParallelAsyncScreenState extends State<ParallelAsyncScreen> {
  late final ParallelDemoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParallelDemoViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
              'Sequential vs Parallel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Future.wait performance',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Concept Card ───────────────────────────────────────────
                _ConceptCard(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: 20),

                // ── Action Panels ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ExecutionPanel(
                        mode: _ExecutionMode.sequential,
                        isRunning: _viewModel.isSequentialRunning,
                        result: _viewModel.sequentialResult,
                        onRun: _viewModel.runSequential,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExecutionPanel(
                        mode: _ExecutionMode.parallel,
                        isRunning: _viewModel.isParallelRunning,
                        result: _viewModel.parallelResult,
                        onRun: _viewModel.runParallel,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Comparison Summary ─────────────────────────────────────
                if (_viewModel.timeSavingsSummary != null)
                  _SavingsBanner(
                    savings: _viewModel.timeSavingsSummary!,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),

                // ── Error Display ──────────────────────────────────────────
                if (_viewModel.errorMessage != null)
                  _ErrorBanner(
                    error: _viewModel.errorMessage!,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),

                const SizedBox(height: 24),

                // ── Code Comparison ────────────────────────────────────────
                _CodeComparisonCard(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: 24),

                // ── When to Use Each ──────────────────────────────────────
                _UsageGuideCard(theme: theme, colorScheme: colorScheme),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 🏷️ Enum for panel mode
// =============================================================================

enum _ExecutionMode { sequential, parallel }

extension _ExecutionModeX on _ExecutionMode {
  String get label =>
      this == _ExecutionMode.sequential ? 'Sequential' : 'Parallel';

  String get expectedTime =>
      this == _ExecutionMode.sequential ? '~3.5 seconds' : '~2.0 seconds';

  IconData get icon =>
      this == _ExecutionMode.sequential ? Icons.linear_scale_rounded : Icons.bolt_rounded;

  Color get color => this == _ExecutionMode.sequential
      ? Colors.orange.shade700
      : Colors.green.shade700;
}

// =============================================================================
// 🧩 Private sub-widgets
// =============================================================================

/// One execution panel (sequential OR parallel) with run button + result.
class _ExecutionPanel extends StatelessWidget {
  final _ExecutionMode mode;
  final bool isRunning;
  final FetchResult? result;
  final Future<void> Function() onRun;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ExecutionPanel({
    required this.mode,
    required this.isRunning,
    required this.result,
    required this.onRun,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = mode.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(102),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRunning
              ? accentColor.withAlpha(153)
              : colorScheme.outlineVariant,
          width: isRunning ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Icon(mode.icon, color: accentColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  mode.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Expected: ${mode.expectedTime}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(128),
            ),
          ),
          const SizedBox(height: 12),

          // ── Run Button ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isRunning ? null : onRun,
              icon: isRunning
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withAlpha(179),
                      ),
                    )
                  : Icon(mode.icon, size: 18),
              label: Text(isRunning ? 'Running…' : 'RUN'),
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Result ────────────────────────────────────────────────────────
          if (result != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 14, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        '${result!.elapsed.inMilliseconds}ms',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '👤 ${result!.data.user.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '📧 ${result!.data.user.email}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📄 ${result!.data.posts.length} posts fetched',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!isRunning) ...[
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Text(
                'Tap RUN to start',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(102),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Green savings banner shown after both runs complete.
class _SavingsBanner extends StatelessWidget {
  final String savings;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SavingsBanner({
    required this.savings,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parallel is $savings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Future.wait ran both operations simultaneously instead of waiting for each to finish.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(204),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Error display banner.
class _ErrorBanner extends StatelessWidget {
  final String error;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ErrorBanner({
    required this.error,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        error,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}

/// Code comparison card showing sequential vs parallel code side-by-side.
class _CodeComparisonCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _CodeComparisonCard({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CODE COMPARISON',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withAlpha(128),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _codeSection(
                theme,
                colorScheme,
                label: '🔴  Sequential (~3.5s)',
                labelColor: Colors.orange.shade700,
                code: '// Each await blocks until done\n'
                    'final user  = await fetchUser();   // 1.5s\n'
                    'final posts = await fetchPosts();  // 2.0s\n'
                    '// Total: 1.5 + 2.0 = 3.5 seconds',
              ),
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16),
              _codeSection(
                theme,
                colorScheme,
                label: '🟢  Parallel (~2.0s)',
                labelColor: Colors.green.shade700,
                code: '// Both futures start SIMULTANEOUSLY\n'
                    'final results = await Future.wait([\n'
                    '  fetchUser(),   // starts at t=0\n'
                    '  fetchPosts(),  // also starts at t=0\n'
                    ']);\n'
                    '// Total: max(1.5, 2.0) = 2.0 seconds',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _codeSection(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String label,
    required Color labelColor,
    required String code,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
        ),
      ],
    );
  }
}

/// Guide explaining when to use sequential vs parallel.
class _UsageGuideCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _UsageGuideCard({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'When to Use Each Pattern',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _guideRow(theme, colorScheme,
              emoji: '🔴',
              title: 'Sequential (await A; await B)',
              when: 'B depends on A\'s result (fetchPosts(userId: user.id))'),
          const SizedBox(height: 8),
          _guideRow(theme, colorScheme,
              emoji: '🟢',
              title: 'Parallel (Future.wait)',
              when:
                  'A and B are independent (user profile + unrelated post list)'),
          const SizedBox(height: 8),
          _guideRow(theme, colorScheme,
              emoji: '⚠️',
              title: 'Future.wait failure behavior',
              when:
                  'If ANY future fails, Future.wait rejects immediately. Use eagerError:false or individual try/catch for partial results.'),
        ],
      ),
    );
  }

  Widget _guideRow(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String emoji,
    required String title,
    required String when,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                when,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reusable concept explanation card.
class _ConceptCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ConceptCard({
    required this.theme,
    required this.colorScheme,
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
              Icon(Icons.bolt_rounded,
                  size: 18, color: colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                'Why Parallel Futures Are Faster',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Dart is single-threaded but I/O is non-blocking',
            'Starting 2 network calls simultaneously → OS handles them in parallel',
            'Total time = max(A, B) instead of A + B',
            'Future.wait([A, B]) returns results in order [A, B]',
            '⚠️ Only use parallel when operations are INDEPENDENT',
          ].map(
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
