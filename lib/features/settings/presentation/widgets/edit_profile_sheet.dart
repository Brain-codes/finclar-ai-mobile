import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_repository_provider.dart';
import 'avatar_choice_sections.dart';

/// The fields the user changed. Null means "leave untouched" — only what
/// actually differs is sent to `PATCH /user/me`.
///
/// `default_currency` is deliberately **not** editable here. The app is
/// naira-only for now; the picker and `AppConfig.supportedCurrencies` are still
/// in place for when multi-currency is turned on.
class EditProfileResult {
  final String? preferredName;
  final String? username;
  final String? profileIcon;

  const EditProfileResult({
    this.preferredName,
    this.username,
    this.profileIcon,
  });

  bool get hasChanges =>
      preferredName != null || username != null || profileIcon != null;
}

/// Edits the account details `PATCH /user/me` accepts. Returns the changed
/// fields, or null when dismissed — the caller persists them.
Future<EditProfileResult?> showEditProfileSheet(
  BuildContext context, {
  required UserModel user,
}) {
  return showAppSheet<EditProfileResult>(
    context,
    title: 'Edit details',
    avoidKeyboard: true,
    children: [_EditProfileContent(user: user)],
  );
}

enum _UsernameStatus { idle, checking, available, taken, error }

class _EditProfileContent extends ConsumerStatefulWidget {
  final UserModel user;
  const _EditProfileContent({required this.user});

  @override
  ConsumerState<_EditProfileContent> createState() =>
      _EditProfileContentState();
}

class _EditProfileContentState extends ConsumerState<_EditProfileContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;

  String? _profileIcon;

  Timer? _debounce;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  String? _usernameError;

  // The username the in-flight check is for. Any response that doesn't match
  // this is stale and must be dropped, otherwise a slow early response can
  // overwrite the verdict for what the user has since typed.
  String? _pendingCheck;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.preferredName ?? '');
    _usernameController = TextEditingController(text: widget.user.username);
    _profileIcon = widget.user.profileIcon;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String get _trimmedUsername => _usernameController.text.trim();

  bool get _usernameChanged => _trimmedUsername != widget.user.username;

  String? _validateUsername(String value) {
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Letters, numbers and underscores only';
    }
    return null;
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    _pendingCheck = null;

    if (!_usernameChanged) {
      setState(() {
        _usernameStatus = _UsernameStatus.idle;
        _usernameError = null;
      });
      return;
    }

    final formatError = _validateUsername(trimmed);
    if (formatError != null) {
      setState(() {
        _usernameStatus = _UsernameStatus.idle;
        _usernameError = formatError;
      });
      return;
    }

    setState(() {
      _usernameStatus = _UsernameStatus.checking;
      _usernameError = null;
    });
    _pendingCheck = trimmed;
    _debounce = Timer(
      const Duration(milliseconds: 600),
      () => _checkUsername(trimmed),
    );
  }

  Future<void> _checkUsername(String username) async {
    try {
      final available = await ref
          .read(authRepositoryProvider)
          .checkUsernameAvailable(username);
      if (!mounted || _pendingCheck != username) return;
      setState(() {
        _usernameStatus = available
            ? _UsernameStatus.available
            : _UsernameStatus.taken;
        _usernameError = available ? null : 'Username is already taken';
      });
    } on AppException catch (e) {
      Log.e('Username check failed', error: e);
      if (!mounted || _pendingCheck != username) return;
      setState(() => _usernameStatus = _UsernameStatus.error);
    }
  }

  bool get _canSave {
    if (_usernameChanged) {
      if (_trimmedUsername.isEmpty) return false;
      if (_validateUsername(_trimmedUsername) != null) return false;
      if (_usernameStatus == _UsernameStatus.checking ||
          _usernameStatus == _UsernameStatus.taken) {
        return false;
      }
    }
    return _hasAnyChange;
  }

  bool get _iconChanged => _profileIcon != widget.user.profileIcon;

  bool get _hasAnyChange {
    final name = _nameController.text.trim();
    return name != (widget.user.preferredName ?? '') ||
        _usernameChanged ||
        _iconChanged;
  }

  void _submit() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      EditProfileResult(
        preferredName:
            name != (widget.user.preferredName ?? '') ? name : null,
        username: _usernameChanged ? _trimmedUsername : null,
        profileIcon: _iconChanged ? _profileIcon : null,
      ),
    );
  }

  Widget? get _usernameSuffix => switch (_usernameStatus) {
        _UsernameStatus.checking => const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        _UsernameStatus.available =>
          const Icon(AppIcons.success, size: 20, color: AppColors.success),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarBlock(
          profileIcon: _profileIcon,
          name: widget.user.displayName,
          recommendedSeeds: recommendedAvatarSeeds(widget.user),
          onSelected: (value) => setState(() => _profileIcon = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: AppStrings.preferredNameLabel,
          hint: AppStrings.preferredNameHint,
          controller: _nameController,
          maxLength: 50,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.base),
        AppTextField(
          label: 'Username',
          hint: 'Your unique @handle',
          controller: _usernameController,
          maxLength: 30,
          errorText: _usernameError,
          suffix: _usernameSuffix,
          onChanged: _onUsernameChanged,
        ),
        const SizedBox(height: AppSpacing.base),
        _ReadOnlyRow(label: 'Email', value: widget.user.email),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Your email can't be changed here — contact support if you need to.",
          style: AppTypography.labelSmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Save changes',
          onTap: _canSave ? _submit : null,
          height: 48,
        ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          decoration: BoxDecoration(
            color: context.surfaceVariant,
            borderRadius: AppRadius.radiusInput,
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium
                      .copyWith(color: context.textSecondary),
                ),
              ),
              Icon(AppIcons.lock, size: 16, color: context.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

/// Current avatar plus the two ready-made sections. Full part-by-part editing
/// lives on its own screen — this sheet only offers the quick picks.
class _AvatarBlock extends StatelessWidget {
  final String? profileIcon;
  final String name;
  final List<String> recommendedSeeds;
  final ValueChanged<String> onSelected;

  const _AvatarBlock({
    required this.profileIcon,
    required this.name,
    required this.recommendedSeeds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            AppProfileAvatar(profileIcon: profileIcon, name: name, size: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Avatar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.settingsAvatar);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Build your own',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AvatarChoiceSections(
          recommendedSeeds: recommendedSeeds,
          selectedValue: profileIcon,
          onSelected: onSelected,
          compact: true,
        ),
      ],
    );
  }
}
