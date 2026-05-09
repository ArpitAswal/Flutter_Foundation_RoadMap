import 'package:flutter/material.dart';
import '../viewmodels/advanced_async_viewmodel.dart';

// =============================================================================
// 🧪 AdvancedAsyncScreen — Completer, StreamController & Isolates
// =============================================================================

class AdvancedAsyncScreen extends StatefulWidget {
  const AdvancedAsyncScreen({super.key});

  @override
  State<AdvancedAsyncScreen> createState() => _AdvancedAsyncScreenState();
}

class _AdvancedAsyncScreenState extends State<AdvancedAsyncScreen> {
  final AdvancedAsyncViewModel _viewModel = AdvancedAsyncViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Async Concepts'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(theme, '🏁 Completer (Manual Future)'),
              _buildCompleterCard(theme),
              const SizedBox(height: 24),
              _buildSectionHeader(theme, '🕹️ StreamController (Manual Stream)'),
              _buildStreamControllerCard(theme),
              const SizedBox(height: 24),
              _buildSectionHeader(theme, '⚡ Isolates (Parallel CPU Work)'),
              _buildIsolateCard(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompleterCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'A Completer allows you to manually complete a Future from anywhere.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: ${_viewModel.completerStatus}',
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _viewModel.startCompleterTask,
                    child: const Text('Start Task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _viewModel.completeTaskSuccessfully,
                    child: const Text('Complete Manually'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamControllerCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'StreamController gives you full control to push events into a stream.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: StreamBuilder<String>(
                stream: _viewModel.chatStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No messages yet...'));
                  }
                  return ListView(
                    reverse: true,
                    children: [
                      Text(snapshot.data!, style: theme.textTheme.bodySmall),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _viewModel.sendMessage('Hello!'),
                ),
              ),
              onSubmitted: (val) => _viewModel.sendMessage(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIsolateCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isolates allow running heavy code without freezing the UI.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_viewModel.isComputing)
              const LinearProgressIndicator()
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Text(_viewModel.computationResult),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _viewModel.isComputing 
                      ? null 
                      : () => _viewModel.runCpuIntensiveTask(useIsolate: false),
                    child: const Text('Main Isolate (Freeze UI)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _viewModel.isComputing 
                      ? null 
                      : () => _viewModel.runCpuIntensiveTask(useIsolate: true),
                    child: const Text('Worker Isolate (Smooth UI)'),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '💡 Try scrolling or interacting while "Main Isolate" is running to see the freeze.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
