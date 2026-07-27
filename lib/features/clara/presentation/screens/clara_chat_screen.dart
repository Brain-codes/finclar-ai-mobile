import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/clara_message_model.dart';
import '../../providers/clara_chat_provider.dart';
import '../widgets/clara_chat_bubble.dart';
import '../widgets/clara_empty_state.dart';
import '../widgets/clara_input_bar.dart';
import '../widgets/clara_insight_card.dart';
import '../widgets/clara_suggestions.dart';
import '../widgets/clara_typing_indicator.dart';

class ClaraChatScreen extends ConsumerStatefulWidget {
  const ClaraChatScreen({super.key});

  @override
  ConsumerState<ClaraChatScreen> createState() => _ClaraChatScreenState();
}

class _ClaraChatScreenState extends ConsumerState<ClaraChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    _scrollToBottom();
    try {
      await ref.read(claraChatProvider.notifier).sendText(trimmed);
      _scrollToBottom();
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(claraChatProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Stack(
        children: [
          const _BackdropBlobs(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _ClaraTopBar(),
                Expanded(child: _Body(state: state, scrollController: _scrollController)),
                ClaraSuggestions(onTap: _send),
                const SizedBox(height: AppSpacing.sm),
                ClaraInputBar(
                  controller: _controller,
                  onSend: () => _send(_controller.text),
                  enabled: !state.isTyping && !state.isLoadingHistory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final ClaraChatState state;
  final ScrollController scrollController;

  const _Body({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.messages.isEmpty) {
      if (state.isLoadingHistory) return const _HistorySkeleton();
      if (state.hasError) {
        return _HistoryError(
          onRetry: () => ref.read(claraChatProvider.notifier).retryHistory(),
        );
      }
      return const ClaraEmptyState();
    }
    return _MessageList(state: state, scrollController: scrollController);
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      children: [
        for (int i = 0; i < 5; i++) ...[
          Align(
            alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
            child: AppSkeleton(
              width: 160 + (i % 3) * 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ],
    );
  }
}

class _HistoryError extends StatelessWidget {
  final VoidCallback onRetry;
  const _HistoryError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.aiFill, size: 32, color: context.textSecondary),
          const SizedBox(height: AppSpacing.base),
          Text(
            "Couldn't load your chat",
            style:
                AppTypography.bodyMedium.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(
                'Retry',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaraTopBar extends StatelessWidget {
  const _ClaraTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : null,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.back, size: 18, color: context.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: AppColors.claraGradient,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(AppIcons.aiFill, size: 15, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Clara AI',
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: AppFonts.display,
                  color: context.textPrimary,
                  fontSize: 16,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ClaraChatState state;
  final ScrollController scrollController;

  const _MessageList({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    String? prevAssistantText;
    for (final msg in state.messages) {
      if (msg.isUser) {
        items.add(ClaraUserBubble(key: ValueKey(msg.id), text: msg.text ?? ''));
        prevAssistantText = null;
      } else if (msg.isInsight) {
        final animate = msg.id == state.animateInsightId;
        // Delay the chart so it appears only once the reply text has typed out
        // (plus a small beat), then let it fade + rise in.
        final prevText = prevAssistantText;
        final delay = animate && prevText != null
            ? claraRevealDuration(prevText) +
                const Duration(milliseconds: 180)
            : Duration.zero;
        items.add(ClaraInsightCard(
          key: ValueKey(msg.id),
          insight: msg.insight!,
          animate: animate,
          startDelay: delay,
        ));
      } else {
        items.add(ClaraAssistantBubble(
          key: ValueKey(msg.id),
          text: msg.text ?? '',
          animate: msg.id == state.animateMessageId,
        ));
        prevAssistantText = msg.text;
      }
      items.add(const SizedBox(height: AppSpacing.base));
    }

    if (state.isTyping) {
      items.add(const ClaraTypingIndicator());
      items.add(const SizedBox(height: AppSpacing.base));
    }

    return ListView(
      controller: scrollController,
      reverse: true,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      children: items.reversed.toList(),
    );
  }
}

class _BackdropBlobs extends StatelessWidget {
  const _BackdropBlobs();

  @override
  Widget build(BuildContext context) {
    if (context.isDark) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -180,
              right: -160,
              child: _Blob(color: AppColors.primary, size: 420),
            ),
            Positioned(
              bottom: -120,
              left: -140,
              child: _Blob(color: const Color(0xFFFA5874), size: 360),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}
