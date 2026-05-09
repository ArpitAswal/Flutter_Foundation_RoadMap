import 'package:flutter/material.dart';
import '../viewmodels/future_demo_viewmodel.dart';
import '../../core/models/user_post.dart';

// =============================================================================
// 📺 FutureBuilderScreen — Task 1: FutureBuilder with loading/error/retry
// =============================================================================
//
// WHAT THIS SCREEN DEMONSTRATES:
//   1. Loading state   → CircularProgressIndicator while future is pending
//   2. Error state     → Error card + Retry button when future throws
//   3. Success state   → Data card showing the fetched UserPost
//   4. Retry pattern   → Replacing the future reference in the ViewModel
//
// MVVM PATTERN:
//   This View owns ZERO business logic. All state lives in FutureDemoViewModel.
//   The View only reads state (via ListenableBuilder) and dispatches events
//   (onPressed callbacks → ViewModel methods).
//
// FUTUREBUILDER INTERNALS:
//   FutureBuilder<T>(future: myFuture, builder: (context, snapshot) { ... })
//
//   snapshot.connectionState can be:
//     ConnectionState.none    → future is null
//     ConnectionState.waiting → future is running (show loading indicator)
//     ConnectionState.done    → future finished (check hasError or hasData)
//
//   snapshot.hasError → future threw an exception (snapshot.error has it)
//   snapshot.hasData  → future completed with a value (snapshot.data has it)
// =============================================================================

/// Task 1: Full FutureBuilder implementation with loading, success, and error states.
class FutureBuilderScreen extends StatefulWidget {
  const FutureBuilderScreen({super.key});

  @override
  State<FutureBuilderScreen> createState() => _FutureBuilderScreenState();
}

class _FutureBuilderScreenState extends State<FutureBuilderScreen> {
  // ---------------------------------------------------------------------------
  // ViewModel is created in initState and disposed in dispose.
  // This is the standard StatefulWidget + ViewModel pattern when NOT using
  // a DI framework (get_it / Provider). The State owns the ViewModel.
  // ---------------------------------------------------------------------------
  late final FutureDemoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // ViewModel is created ONCE and the future starts immediately (in ViewModel's constructor)
    _viewModel = FutureDemoViewModel();
  }

  @override
  void dispose() {
    // ViewModel is a ChangeNotifier — if it had streams/timers, they'd be
    // cancelled here. Always dispose ViewModels to prevent leaks.
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
              'FutureBuilder Demo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Async data loading',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
        // Error simulation toggle — calls ViewModel, no logic in View
        actions: [
          // ListenableBuilder rebuilds ONLY this action area when ViewModel notifies
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Row(
              children: [
                Tooltip(
                  message: _viewModel.simulateError
                      ? 'Error mode ON — tap to disable'
                      : 'Error mode OFF — tap to enable',
                  child: Switch.adaptive(
                    value: _viewModel.simulateError,
                    activeThumbColor: colorScheme.error,
                    onChanged: (_) => _viewModel.toggleErrorSimulation(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Concept Explanation Card ──────────────────────────────────────
            _ConceptCard(
              theme: theme,
              colorScheme: colorScheme,
              icon: Icons.lightbulb_outline_rounded,
              title: 'How FutureBuilder Works',
              points: const [
                '1. Future is created ONCE in initState (via ViewModel)',
                '2. FutureBuilder rebuilds UI on state changes',
                '3. ConnectionState.waiting → show progress indicator',
                '4. snapshot.hasError → show error + retry button',
                '5. snapshot.hasData → show the loaded content',
              ],
            ),
            const SizedBox(height: 8),

            // ── Error Simulation Notice ───────────────────────────────────────
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (!_viewModel.simulateError) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error simulation is ON. The API call will throw an exception.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── FutureBuilder Area ────────────────────────────────────────────
            // IMPORTANT: We wrap FutureBuilder in ListenableBuilder so that when
            // the ViewModel calls notifyListeners() (e.g., on retry), this widget
            // rebuilds and passes the NEW future reference to FutureBuilder.
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return FutureBuilder<UserPost>(
                  // The future reference comes from the ViewModel — NOT from a
                  // method call directly in build(). This is the critical pattern.
                  future: _viewModel.userPostFuture,
                  builder: (context, snapshot) {
                    // ── Loading ───────────────────────────────────────────────
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingState();
                    }

                    // ── Error ─────────────────────────────────────────────────
                    if (snapshot.hasError) {
                      return _ErrorState(
                        error: snapshot.error.toString(),
                        onRetry: _viewModel.retry,
                      );
                    }

                    // ── Success ───────────────────────────────────────────────
                    if (snapshot.hasData) {
                      return _SuccessState(post: snapshot.data!);
                    }

                    // ── Fallback (shouldn't happen in practice) ───────────────
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🧩 Sub-widgets (private — only used by FutureBuilderScreen)
// =============================================================================

/// Loading indicator shown while ConnectionState.waiting
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Fetching post from server…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Simulating 2s network delay)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(102),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error card with retry button shown when snapshot.hasError is true.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Request Failed',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.error.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '💡 Production tip: Log the full stackTrace too.\n'
            'Check mounted before calling setState after an async error.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer.withAlpha(179),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Request'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Success card displaying the fetched UserPost data.
class _SuccessState extends StatelessWidget {
  final UserPost post;

  const _SuccessState({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // ── Success banner ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withAlpha(77)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                'Future completed with value ✅',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Post Card ────────────────────────────────────────────────────────
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        post.authorName.substring(0, 1),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          post.createdAt,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            color: Colors.red.shade400, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(179),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable concept explanation card used throughout the module screens.
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
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
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
