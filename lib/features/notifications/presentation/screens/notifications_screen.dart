import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notifications_provider.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_list_skeleton.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

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
                    child: Text(
                      AppStrings.markAllRead,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontVariations: const [FontVariation('wght', 600)],
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
          ),
        ),
    ];
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
