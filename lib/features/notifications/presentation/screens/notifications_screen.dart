import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notifications_provider.dart';
import '../widgets/notification_action_utils.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_list_skeleton.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // `notificationsProvider` is not autoDispose, so its first build — triggered
    // from Home's badge at launch — would otherwise be the only fetch the app
    // ever makes. Anything that arrives after launch (an invite, a budget alert)
    // would never show until the user pulled to refresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final isLoadingMore = ref.watch(notificationsLoadingMoreProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: AppStrings.notifications,
              circleBack: true,
              onBack: () {
                if (context.canPop()) context.pop();
              },
              actions: [
                if (unread > 0)
                  GestureDetector(
                    onTap: () =>
                        ref.read(notificationsProvider.notifier).markAllRead(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryMuted,
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        AppStrings.markAllRead,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.base,
                    AppSpacing.screenPadding,
                    0,
                  ),
                  child: NotificationListSkeleton(),
                ),
                error: (_, _) => _ErrorState(
                  onRetry: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.base,
                        AppSpacing.screenPadding,
                        0,
                      ),
                      child: NotificationEmptyState(),
                    );
                  }
                  final today =
                      items.where((n) => _isToday(n.createdAt)).toList();
                  final earlier =
                      items.where((n) => !_isToday(n.createdAt)).toList();

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.base,
                        AppSpacing.screenPadding,
                        AppSpacing.xxl,
                      ),
                      children: [
                        if (today.isNotEmpty) ...[
                          _SectionLabel(AppStrings.notificationsToday),
                          ..._tiles(ref, today),
                        ],
                        if (earlier.isNotEmpty) ...[
                          if (today.isNotEmpty)
                            const SizedBox(height: AppSpacing.lg),
                          _SectionLabel(AppStrings.notificationsEarlier),
                          ..._tiles(ref, earlier),
                        ],
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.sm),
                            child: NotificationTileSkeleton(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tiles(WidgetRef ref, List<NotificationModel> items) {
    return [
      for (final n in items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: NotificationTile(
            notification: n,
            onTap: () =>
                ref.read(notificationsProvider.notifier).markRead(n.id),
            onMarkRead: () =>
                ref.read(notificationsProvider.notifier).markRead(n.id),
            onAction: () => _openAction(ref, n),
          ),
        ),
    ];
  }

  void _openAction(WidgetRef ref, NotificationModel n) {
    final action = notificationActionFor(n.type);
    if (action == null) return;
    // Acting on a notification implies reading it — the optimistic update means
    // the badge is already right by the time the next screen paints.
    ref.read(notificationsProvider.notifier).markRead(n.id);
    context.push(action.route);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: context.textSecondary,
          fontVariations: const [FontVariation('wght', 600)],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.somethingWentWrong,
              style: AppTypography.bodyMedium
                  .copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                AppStrings.retry,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
