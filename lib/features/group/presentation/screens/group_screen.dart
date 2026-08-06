import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/group_model.dart';
import '../../providers/group_providers.dart';
import '../widgets/group_card.dart';
import '../widgets/group_empty_state.dart';
import '../widgets/group_invite_card.dart';

// Cycled accent colors for the group cards (backend has no per-group color).
const _groupThemeColors = [
  AppColors.primary,
  AppColors.categoryShopping,
  AppColors.warning,
  AppColors.categoryHealth,
];

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: groupsState.when(
          loading: () => const _LoadingState(),
          error: (e, _) => _ErrorState(
            onRetry: () => ref.read(groupsProvider.notifier).refresh(),
          ),
          data: (groups) => groups.isEmpty
              ? _EmptyState(onCreateGroup: () => _onCreateGroup(context))
              : _FilledState(
                  groups: groups,
                  onRefresh: () =>
                      ref.read(groupsProvider.notifier).refresh(),
                ),
        ),
      ),
    );
  }

  void _onCreateGroup(BuildContext context) =>
      context.push(RouteNames.createGroup);
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.base),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.base),
            itemBuilder: (_, _) => const _GroupCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AppSkeleton.text(width: 140),
          SizedBox(height: 10),
          AppSkeleton.text(width: 100, height: 12),
          SizedBox(height: 12),
          AppSkeleton(width: double.infinity, height: 14),
          SizedBox(height: 12),
          AppSkeleton(width: double.infinity, height: 28),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _EmptyState({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return GroupEmptyState(onCreateGroup: onCreateGroup);
  }
}

class _FilledState extends ConsumerStatefulWidget {
  final List<GroupModel> groups;
  final Future<void> Function() onRefresh;

  const _FilledState({
    required this.groups,
    required this.onRefresh,
  });

  @override
  ConsumerState<_FilledState> createState() => _FilledStateState();
}

class _FilledStateState extends ConsumerState<_FilledState> {
  final Set<String> _responding = {};

  Future<void> _respond(GroupModel g, bool accept) async {
    if (_responding.contains(g.id)) return;
    setState(() => _responding.add(g.id));
    try {
      await ref
          .read(groupsProvider.notifier)
          .respondToInvite(g.id, accept: accept);
      if (mounted) {
        AppSnackbar.success(
          context,
          accept ? 'Joined ${g.name}' : 'Invite declined',
        );
      }
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _responding.remove(g.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);

    final invites = widget.groups.where((g) => g.isInvitePending).toList();
    final active = widget.groups.where((g) => !g.isInvitePending).toList();

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding + 72,
              ),
              children: [
                if (invites.isNotEmpty) ...[
                  _SectionLabel('Invitations (${invites.length})'),
                  const SizedBox(height: AppSpacing.sm),
                  for (final g in invites) ...[
                    GroupInviteCard(
                      name: g.name,
                      target: formatCurrency(g.targetAmount, symbol,
                          abbreviate: false, withCommas: true),
                      memberCount: g.memberCount,
                      isResponding: _responding.contains(g.id),
                      onAccept: () => _respond(g, true),
                      onDecline: () => _respond(g, false),
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _SectionLabel('Your groups'),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (active.isEmpty && invites.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base),
                    child: Text(
                      "You haven't joined any groups yet.",
                      style: AppTypography.bodySmall
                          .copyWith(color: context.textSecondary),
                    ),
                  ),
                for (var i = 0; i < active.length; i++) ...[
                  Builder(builder: (context) {
                    final g = active[i];
                    final color =
                        _groupThemeColors[i % _groupThemeColors.length];
                    return GroupCard(
                      name: g.name,
                      amountSaved: formatCurrency(g.totalRaised, symbol,
                          abbreviate: false, withCommas: true),
                      daysLeft: g.daysLeftLabel,
                      target: formatCurrency(g.targetAmount, symbol,
                          abbreviate: false, withCommas: true),
                      progress: g.progress,
                      themeColor: color,
                      onTap: () =>
                          context.push(RouteNames.groupDetail, extra: g),
                    );
                  }),
                  if (i < active.length - 1)
                    const SizedBox(height: AppSpacing.base),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.bodyMedium.copyWith(
        color: context.textSecondary,
        fontVariations: const [FontVariation('wght', 500)],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.group, size: 40, color: context.textSecondary),
                const SizedBox(height: AppSpacing.base),
                Text(
                  "Couldn't load your groups",
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textQuaternary,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
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
                      borderRadius:
                          BorderRadius.all(Radius.circular(100)),
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
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.borderColor),
        ),
        child: Icon(icon, size: 20, color: context.textSecondary),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Group',
            style: AppTypography.headingLarge.copyWith(
              color: context.textPrimary,
            ),
          ),
          Row(
            children: [
              _HeaderAction(
                icon: AppIcons.addUser,
                onTap: () => context.push(RouteNames.friends),
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderAction(
                icon: AppIcons.add,
                onTap: () => context.push(RouteNames.createGroup),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
