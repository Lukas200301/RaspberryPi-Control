import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';
import 'cards.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Tone tone;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.tone = Tone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon, tone: tone == Tone.neutral ? Tone.primary : tone, size: 72),
              const Gap(Insets.lg),
              Text(
                title,
                style: context.tt.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const Gap(Insets.sm),
                Text(
                  message!,
                  style: context.tt.bodyMedium?.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const Gap(Insets.xl), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final Object error;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      tone: Tone.danger,
      title: title,
      message: describeError(error),
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
    );
  }
}

/// Turns exceptions into a readable sentence
String describeError(Object error) {
  var text = error.toString();
  for (final prefix in ['Exception: ', 'Bad state: ']) {
    if (text.startsWith(prefix)) text = text.substring(prefix.length);
  }
  if (text.contains('gRPC Error (code: 14')) {
    return 'The agent is not reachable. Check the connection to your Pi.';
  }
  if (text.contains('gRPC Error (code: 12')) {
    return 'The agent on your Pi is too old for this feature. Update the agent.';
  }
  return text;
}

class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const Gap(Insets.lg),
            Text(
              message!,
              style: context.tt.bodyMedium?.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders an AsyncValue with the standard loading and error states. Keeps
/// showing the last data while refreshing.
class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: data,
      loading: () => LoadingState(message: loadingMessage),
      error: (e, _) => ErrorState(error: e, onRetry: onRetry),
    );
  }
}
