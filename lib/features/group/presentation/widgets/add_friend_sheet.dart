import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

// Returns the added friend's display name, or null if cancelled.
Future<String?> showAddFriendSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddFriendSheet(),
  );
}

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet();

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    // Mock: result appears when query starts with 's'
    final hasResult = hasQuery && _query.trim().toLowerCase().startsWith('s');

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add friends',
                style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
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
                  child: Icon(AppIcons.close, size: 14, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Search field — styled like AppTextField
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) => setState(() => _query = v),
            keyboardAppearance: context.isDark ? Brightness.dark : Brightness.light,
            style: AppTypography.bodyMedium.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add friends on finclar',
              hintStyle: AppTypography.bodyMedium.copyWith(color: context.inputPlaceholder),
              filled: true,
              fillColor: context.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: hasQuery
                  ? null
                  : Icon(AppIcons.search, size: 18, color: context.textTertiary),
              suffixIcon: hasQuery
                  ? GestureDetector(
                      onTap: _clear,
                      child: Icon(AppIcons.close, size: 18, color: context.textTertiary),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusInput,
                borderSide: BorderSide(color: context.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusInput,
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.base),

          // Results area
          Expanded(
            child: hasQuery && !hasResult
                ? _NoResultState(query: _query.trim())
                : hasResult
                    ? _FriendResultTile(
                        name: 'Segun Martin',
                        username: 'segxy',
                        avatarColor: const Color(0xFFB8DFF2),
                        onAdd: () => Navigator.of(context).pop('Segun Martin'),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NoResultState extends StatelessWidget {
  final String query;

  const _NoResultState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.search, size: 32, color: context.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No search result for "$query"',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FriendResultTile extends StatelessWidget {
  final String name;
  final String username;
  final Color avatarColor;
  final VoidCallback onAdd;

  const _FriendResultTile({
    required this.name,
    required this.username,
    required this.avatarColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Text(
                  '@$username',
                  style: AppTypography.labelSmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: context.scaffoldColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.borderColor),
              ),
              child: Text(
                'Add',
                style: AppTypography.labelSmall.copyWith(color: context.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
