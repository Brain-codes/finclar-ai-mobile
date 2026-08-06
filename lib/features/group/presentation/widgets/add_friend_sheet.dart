import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/friendship_model.dart';
import '../../providers/friend_providers.dart';
import 'invite_friend_sheet.dart';

enum AddFriendMode {
  /// Returns the picked user to the caller (group member flow).
  selectUser,

  /// Sends a friend request in place and stays open.
  sendRequest,
}

/// Search finclar users. In [AddFriendMode.selectUser] returns the selected
/// user; in [AddFriendMode.sendRequest] it sends the request itself and
/// returns null. [excludeIds] hides users already added.
Future<UserSearchResultModel?> showAddFriendSheet(
  BuildContext context, {
  Set<String> excludeIds = const {},
  AddFriendMode mode = AddFriendMode.selectUser,
  String? initialQuery,
}) {
  return showAppSheet<UserSearchResultModel>(
    context,
    title: 'Add friends',
    avoidKeyboard: true,
    heightFactor: 0.91,
    children: [
      _AddFriendContent(
        excludeIds: excludeIds,
        mode: mode,
        initialQuery: initialQuery,
      ),
    ],
  );
}

enum _TileState { idle, sending, sent, alreadyFriends }

class _AddFriendContent extends ConsumerStatefulWidget {
  final Set<String> excludeIds;
  final AddFriendMode mode;
  final String? initialQuery;

  const _AddFriendContent({
    required this.excludeIds,
    required this.mode,
    this.initialQuery,
  });

  @override
  ConsumerState<_AddFriendContent> createState() => _AddFriendContentState();
}

class _AddFriendContentState extends ConsumerState<_AddFriendContent> {
  late final TextEditingController _controller;
  Timer? _debounce;
  String _query = '';

  // Per-user override of the tile state, for requests sent in this session.
  final Map<String, _TileState> _sent = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _query = widget.initialQuery?.trim() ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  Future<void> _onAdd(UserSearchResultModel user) async {
    if (widget.mode == AddFriendMode.selectUser) {
      Navigator.of(context).pop(user);
      return;
    }

    setState(() => _sent[user.id] = _TileState.sending);
    try {
      await ref.read(friendInvitesProvider.notifier).invite(user.id);
      if (!mounted) return;
      setState(() => _sent[user.id] = _TileState.sent);
      AppSnackbar.success(context, 'Request sent to ${user.username}');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _sent.remove(user.id));
      AppSnackbar.error(context, e.message);
    }
  }

  _TileState _stateFor(
    UserSearchResultModel user,
    Set<String> friendIds,
    Set<String> pendingIds,
  ) {
    if (_sent.containsKey(user.id)) return _sent[user.id]!;
    if (friendIds.contains(user.id)) return _TileState.alreadyFriends;
    if (pendingIds.contains(user.id)) return _TileState.sent;
    return _TileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    final results = hasQuery
        ? ref.watch(userSearchProvider(_query))
        : const AsyncData<List<UserSearchResultModel>>([]);

    // Only relevant when the sheet sends requests itself; in select mode the
    // caller owns which users are already in the group via excludeIds.
    final isRequestMode = widget.mode == AddFriendMode.sendRequest;
    final friendIds = isRequestMode
        ? (ref.watch(friendsProvider).valueOrNull ?? [])
            .map((f) => f.friendId)
            .toSet()
        : <String>{};
    final pendingIds = isRequestMode
        ? (ref.watch(friendInvitesProvider).valueOrNull ?? [])
            .map((f) => f.friendId)
            .toSet()
        : <String>{};

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Search',
            hint: 'To search friends, enter Username',
            controller: _controller,
            onChanged: _onChanged,
            autofocus: true,
            prefix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(AppIcons.search, size: 18, color: context.textTertiary),
            ),
            prefixConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          const SizedBox(height: AppSpacing.base),
          Expanded(
            child: !hasQuery
                ? const _IdleHint()
                : results.when(
                    loading: () => const _ResultsSkeleton(),
                    error: (_, _) =>
                        _EmptyState(query: _query, isError: true, mode: widget.mode),
                    data: (users) {
                      final visible = users
                          .where((u) => !widget.excludeIds.contains(u.id))
                          .toList();
                      if (visible.isEmpty) {
                        return _EmptyState(
                          query: _query,
                          isError: false,
                          mode: widget.mode,
                        );
                      }
                      return ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final u = visible[i];
                          return _FriendResultTile(
                            user: u,
                            state: _stateFor(u, friendIds, pendingIds),
                            onAdd: () => _onAdd(u),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown before the user types. States the search rules up front — the old
/// sheet showed nothing, so "typed a name, got nothing" read as a broken
/// feature rather than "that person isn't on finclar".
class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.search, size: 32, color: context.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Search a friend by their username',
            style: AppTypography.bodySmall.copyWith(color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'They need a finclar account to show up here.',
              style:
                  AppTypography.labelSmall.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  final String query;
  final bool isError;
  final AddFriendMode mode;

  const _EmptyState({
    required this.query,
    required this.isError,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? AppIcons.refresh : AppIcons.search,
            size: 32,
            color: context.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isError
                ? 'Something went wrong, try again'
                : 'No one on finclar with the username "$query" matches',
            style: AppTypography.bodySmall.copyWith(color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (!isError) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Check the spelling, or invite them to join.',
                style: AppTypography.labelSmall
                    .copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _InviteButton(onTap: () => showInviteFriendSheet(context, ref)),
          ],
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryMuted,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.share, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Invite to finclar',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const Row(
        children: [
          AppSkeleton.circle(size: 40),
          SizedBox(width: 12),
          AppSkeleton.text(width: 140),
        ],
      ),
    );
  }
}

class _FriendResultTile extends StatelessWidget {
  final UserSearchResultModel user;
  final _TileState state;
  final VoidCallback onAdd;

  const _FriendResultTile({
    required this.user,
    required this.state,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          AppProfileAvatar(
            profileIcon: null,
            name: user.username,
            size: 40,
            seedWhenEmpty: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall
                      .copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          _TileAction(state: state, onAdd: onAdd),
        ],
      ),
    );
  }
}

class _TileAction extends StatelessWidget {
  final _TileState state;
  final VoidCallback onAdd;

  const _TileAction({required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    if (state == _TileState.sending) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final label = switch (state) {
      _TileState.sent => 'Pending',
      _TileState.alreadyFriends => 'Friends',
      _ => 'Add',
    };
    final isActionable = state == _TileState.idle;

    return GestureDetector(
      onTap: isActionable ? onAdd : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: isActionable ? context.scaffoldColor : context.surfaceVariant,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActionable ? context.textPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}
