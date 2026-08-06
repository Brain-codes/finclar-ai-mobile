import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../data/models/friendship_model.dart';
import '../../providers/friend_providers.dart';

/// Search finclar users and add one. Returns the selected user, or null if
/// cancelled. [excludeIds] hides users already added.
Future<UserSearchResultModel?> showAddFriendSheet(
  BuildContext context, {
  Set<String> excludeIds = const {},
}) {
  return showModalBottomSheet<UserSearchResultModel>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddFriendSheet(excludeIds: excludeIds),
  );
}

class _AddFriendSheet extends ConsumerStatefulWidget {
  final Set<String> excludeIds;
  const _AddFriendSheet({required this.excludeIds});

  @override
  ConsumerState<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<_AddFriendSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    final results = hasQuery
        ? ref.watch(userSearchProvider(_query))
        : const AsyncData<List<UserSearchResultModel>>([]);

    return Container(
      height: MediaQuery.of(context).size.height * 0.91,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add friends',
                style: AppTypography.headingSmall
                    .copyWith(color: context.textPrimary),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.scaffoldColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Icon(AppIcons.close,
                      size: 14, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            keyboardAppearance:
                context.isDark ? Brightness.dark : Brightness.light,
            style: AppTypography.bodyMedium.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add friends on finclar',
              hintStyle: AppTypography.bodyMedium
                  .copyWith(color: context.inputPlaceholder),
              filled: true,
              fillColor: context.inputFill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: _controller.text.isEmpty
                  ? Icon(AppIcons.search,
                      size: 18, color: context.textTertiary)
                  : null,
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : GestureDetector(
                      onTap: _clear,
                      child: Icon(AppIcons.close,
                          size: 18, color: context.textTertiary),
                    ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusInput,
                borderSide: BorderSide(color: context.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusInput,
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Expanded(
            child: !hasQuery
                ? const SizedBox.shrink()
                : results.when(
                    loading: () => ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, _) => Row(
                        children: const [
                          AppSkeleton.circle(size: 40),
                          SizedBox(width: 12),
                          AppSkeleton.text(width: 140),
                        ],
                      ),
                    ),
                    error: (_, _) =>
                        _NoResultState(query: _query, isError: true),
                    data: (users) {
                      final visible = users
                          .where((u) => !widget.excludeIds.contains(u.id))
                          .toList();
                      if (visible.isEmpty) {
                        return _NoResultState(query: _query, isError: false);
                      }
                      return ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final u = visible[i];
                          return _FriendResultTile(
                            user: u,
                            onAdd: () => Navigator.of(context).pop(u),
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

class _NoResultState extends StatelessWidget {
  final String query;
  final bool isError;

  const _NoResultState({required this.query, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.search, size: 32, color: context.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isError
                ? 'Something went wrong, try again'
                : 'No search result for "$query"',
            style:
                AppTypography.bodySmall.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FriendResultTile extends StatelessWidget {
  final UserSearchResultModel user;
  final VoidCallback onAdd;

  const _FriendResultTile({required this.user, required this.onAdd});

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
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: AppTypography.labelSmall
                      .copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: context.scaffoldColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.borderColor),
              ),
              child: Text(
                'Add',
                style: AppTypography.labelSmall
                    .copyWith(color: context.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
