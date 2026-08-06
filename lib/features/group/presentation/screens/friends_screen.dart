import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../data/models/friendship_model.dart';
import '../../providers/friend_providers.dart';
import '../widgets/add_friend_sheet.dart';
import '../widgets/friend_request_tile.dart';
import '../widgets/friend_tile.dart';
import '../widgets/invite_friend_sheet.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  Future<void> _onAddFriends(BuildContext context) async {
    await showAddFriendSheet(context, mode: AddFriendMode.sendRequest);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(userProfileProvider).valueOrNull?.id;
    final friends = ref.watch(friendsProvider);
    final invites = ref.watch(friendInvitesProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              onBack: () => context.pop(),
              title: 'Friends',
              centerTitle: false,
              actions: [
                AppTopBarAction(
                  icon: AppIcons.addUser,
                  onTap: () => _onAddFriends(context),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(friendsProvider.notifier).refresh();
                  await ref.read(friendInvitesProvider.notifier).refresh();
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.base,
                  ),
                  children: [
                    _RequestsSection(
                      invites: invites,
                      currentUserId: currentUserId,
                    ),
                    _FriendsSection(friends: friends),
                    const SizedBox(height: AppSpacing.xl),
                    _InviteCta(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(
          color: context.textPrimary,
          fontVariations: const [FontVariation('wght', 600)],
        ),
      ),
    );
  }
}

class _RequestsSection extends ConsumerWidget {
  final AsyncValue<List<FriendshipModel>> invites;
  final String? currentUserId;

  const _RequestsSection({required this.invites, required this.currentUserId});

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    FriendshipModel invite, {
    required bool accept,
  }) async {
    try {
      final notifier = ref.read(friendInvitesProvider.notifier);
      accept ? await notifier.accept(invite.id) : await notifier.decline(invite.id);
      if (context.mounted) {
        AppSnackbar.success(
          context,
          accept
              ? 'You and ${invite.friendUsername} are now friends'
              : 'Request declined',
        );
      }
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return invites.when(
      loading: () => const _ListSkeleton(rows: 2),
      // A failed invites fetch shouldn't blank the friends list below it.
      error: (_, _) => const SizedBox.shrink(),
      data: (all) {
        // Only requests waiting on *this* user need an action. Ones we sent
        // are shown as pending inside the add-friend sheet instead.
        final incoming = all
            .where((f) => f.isPending && f.recipientId == currentUserId)
            .toList();
        if (incoming.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Friend requests (${incoming.length})'),
            for (final invite in incoming) ...[
              FriendRequestTile(
                invite: invite,
                onAccept: () => _act(context, ref, invite, accept: true),
                onDecline: () => _act(context, ref, invite, accept: false),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.base),
          ],
        );
      },
    );
  }
}

class _FriendsSection extends ConsumerWidget {
  final AsyncValue<List<FriendshipModel>> friends;
  const _FriendsSection({required this.friends});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('My friends'),
        friends.when(
          loading: () => const _ListSkeleton(rows: 4),
          error: (_, _) => _ErrorRow(
            onRetry: () => ref.read(friendsProvider.notifier).refresh(),
          ),
          data: (list) {
            final accepted = list.where((f) => f.isAccepted).toList();
            if (accepted.isEmpty) return const _EmptyFriends();
            return Column(
              children: [
                for (final f in accepted) ...[
                  FriendTile(friendship: f),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(AppIcons.addUser, size: 32, color: context.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No friends yet',
            style: AppTypography.bodyMedium.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add people you split and save with.',
            textAlign: TextAlign.center,
            style:
                AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InviteCta extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Invite a friend to finclar',
      variant: AppButtonVariant.outline,
      icon: AppIcons.share,
      onTap: () => showInviteFriendSheet(context, ref),
      height: 48,
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRow({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: GestureDetector(
          onTap: onRetry,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Icon(AppIcons.refresh, size: 20, color: context.textSecondary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Couldn't load. Tap to retry",
                style: AppTypography.bodySmall
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  final int rows;
  const _ListSkeleton({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < rows; i++) ...[
          const Row(
            children: [
              AppSkeleton.circle(size: 40),
              SizedBox(width: 12),
              Expanded(child: AppSkeleton.text(width: double.infinity)),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ],
    );
  }
}
