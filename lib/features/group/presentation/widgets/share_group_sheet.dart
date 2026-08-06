import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/invite_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_snackbar.dart';

Future<void> showShareGroupSheet(
  BuildContext context, {
  required String groupName,
  required String shareLink,
  required List<String> memberNames,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ShareGroupSheet(
      groupName: groupName,
      shareLink: shareLink,
      memberNames: memberNames,
    ),
  );
}

class _ShareGroupSheet extends StatelessWidget {
  final String groupName;
  final String shareLink;
  final List<String> memberNames;

  const _ShareGroupSheet({
    required this.groupName,
    required this.shareLink,
    required this.memberNames,
  });

  String get _message =>
      'Join my "$groupName" group on finclar — $shareLink';

  Future<void> _shareSheet() => InviteService.shareText(_message);

  Future<void> _channel(Future<bool> Function(String) action) async {
    final launched = await action(_message);
    // The app isn't installed — fall back rather than doing nothing.
    if (!launched) await _shareSheet();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Share',
                style: AppTypography.headingSmall.copyWith(
                  color: context.textPrimary,
                  fontFamily: AppFonts.display,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.scaffoldColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderStrong),
                  ),
                  child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Group avatar + name
          Column(
            children: [
              SizedBox(
                width: 96,
                height: 56,
                child: Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5ECFD),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    Positioned(
                      left: 40,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBD1FC),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                groupName,
                style: AppTypography.headingLarge.copyWith(
                  color: context.textPrimary,
                  fontFamily: AppFonts.display,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Share link pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 14),
            decoration: BoxDecoration(
              color: context.scaffoldColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderStrong),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    shareLink,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textQuaternary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareLink));
                    AppSnackbar.success(context, 'Link copied to clipboard');
                    Navigator.of(context).pop();
                  },
                  child: Icon(AppIcons.copy, size: 20, color: context.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Members card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.borderColor),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: memberNames.map((name) {
                  final initials = name
                      .trim()
                      .split(' ')
                      .map((w) => w.isNotEmpty ? w[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase();
                  const colors = [
                    Color(0xFFC5ECFD),
                    Color(0xFFDBD1FC),
                    Color(0xFFD7D7D9),
                    Color(0xFFD7D7D9),
                    Color(0xFFDBD1FC),
                  ];
                  final idx = memberNames.indexOf(name) % colors.length;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.base),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors[idx],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textPrimary,
                                fontVariations: const [FontVariation('wght', 600)],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name.split(' ').first,
                          style: AppTypography.labelSmall.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Social share apps card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShareAppIcon(
                  label: 'Whatsapp',
                  icon: AppIcons.whatsapp,
                  color: const Color(0xFF25D366),
                  onTap: () => _channel(InviteService.textToWhatsApp),
                ),
                _ShareAppIcon(
                  label: 'Telegram',
                  icon: AppIcons.send,
                  color: const Color(0xFF2CA5E0),
                  onTap: _shareSheet,
                ),
                _ShareAppIcon(
                  label: 'Gmail',
                  icon: AppIcons.email,
                  color: const Color(0xFFEA4335),
                  onTap: () => _channel(
                    (t) => InviteService.textToEmail(
                      t,
                      subject: 'Join my finclar group',
                    ),
                  ),
                ),
                _ShareAppIcon(
                  label: 'Message',
                  icon: AppIcons.chat,
                  color: const Color(0xFF34C759),
                  onTap: () => _channel(InviteService.textToSms),
                ),
                // Instagram has no text-share intent — the OS sheet is the
                // only honest route to it.
                _ShareAppIcon(
                  label: 'Instagram',
                  icon: AppIcons.instagram,
                  color: const Color(0xFFD00B41),
                  onTap: _shareSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareAppIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShareAppIcon({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style:
                AppTypography.labelSmall.copyWith(color: context.textTertiary),
          ),
        ],
      ),
    );
  }
}
