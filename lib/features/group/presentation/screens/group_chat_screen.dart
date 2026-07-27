import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/auth/providers/user_profile_provider.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/group_message_model.dart';
import '../../data/models/group_model.dart';
import '../../providers/group_messages_provider.dart';
import '../../providers/group_providers.dart';
import '../widgets/group_chat_bubble.dart';
import '../widgets/group_chat_input_bar.dart';
import '../widgets/group_chat_media_preview.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  bool _sending = false;

  String get _groupId => widget.group.id;

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    _messageController.clear();
    setState(() => _sending = true);
    try {
      await ref.read(groupMessagesProvider(_groupId).notifier).sendText(text);
      _scrollToBottom();
    } on AppException catch (e) {
      if (mounted) {
        _messageController.text = text;
        AppSnackbar.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _handleCamera() => _pickAndSend(ImageSource.camera);

  Future<void> _handleAttachment() async {
    final source = await showAppSheet<String>(
      context,
      title: 'Attach media',
      children: [
        _SourceTile(
          icon: AppIcons.camera,
          label: 'Take a photo',
          onTap: (ctx) => Navigator.of(ctx).pop('camera'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SourceTile(
          icon: AppIcons.image,
          label: 'Choose from library',
          onTap: (ctx) => Navigator.of(ctx).pop('gallery'),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
    if (source == null || !mounted) return;
    await _pickAndSend(
      source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
  }

  Future<void> _pickAndSend(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    final result = await showGroupChatMediaPreview(context, filePath: image.path);
    if (result == null || !mounted) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(groupMessagesProvider(_groupId).notifier)
          .sendAttachment(File(result.filePath));
      // The caption, if any, follows as a separate text message.
      if (result.caption.isNotEmpty) {
        await ref
            .read(groupMessagesProvider(_groupId).notifier)
            .sendText(result.caption);
      }
      _scrollToBottom();
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(groupMessagesProvider(_groupId));
    final currentUserId = ref.watch(userProfileProvider).valueOrNull?.id;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ChatTopBar(group: widget.group),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: messagesState.when(
                  loading: () => const _ChatSkeleton(),
                  error: (_, _) => _ChatError(
                    onRetry: () => ref
                        .read(groupMessagesProvider(_groupId).notifier)
                        .refresh(),
                  ),
                  data: (messages) => messages.isEmpty
                      ? const _ChatEmpty()
                      : _ChatMessageList(
                          messages: messages,
                          currentUserId: currentUserId,
                          scrollController: _scrollController,
                        ),
                ),
              ),
            ),
            GroupChatInputBar(
              controller: _messageController,
              onSend: _handleSend,
              onCamera: _handleCamera,
              onAttachment: _handleAttachment,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext ctx) onTap;
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                fontSize: 15,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _ChatTopBar extends ConsumerWidget {
  final GroupModel group;
  const _ChatTopBar({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(groupDetailProvider(group.id)).valueOrNull;
    final members = detail?.members ?? const [];
    final count = detail?.memberCount ?? group.memberCount;

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
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.back, size: 16, color: context.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: AppFonts.display,
                      color: context.textPrimary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (members.isNotEmpty)
                  SizedBox(
                    height: 32,
                    width: members.length > 1 ? 48 : 32,
                    child: Stack(
                      children: [
                        for (int i = 0; i < members.take(2).length; i++)
                          Positioned(
                            left: i * 16.0,
                            child: AppAvatar(
                              initials: members[i].username,
                              size: 32,
                              border: Border.all(
                                  color: AppColors.white, width: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  group.name,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: AppFonts.display,
                    color: context.textPrimary,
                    fontSize: 16,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteNames.groupFriends, extra: group),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.borderColor),
              ),
              child: Text(
                '$count ${count == 1 ? 'friend' : 'friends'}',
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: AppFonts.display,
                  color: context.textPrimary,
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

// ─── Message list ─────────────────────────────────────────────────────────────

class _ChatMessageList extends StatelessWidget {
  final List<GroupMessageModel> messages;
  final String? currentUserId;
  final ScrollController scrollController;

  const _ChatMessageList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
  });

  static final _dateFmt = DateFormat('EEE, MMM d');

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    String? prevSenderId;
    DateTime? prevDate;

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final date = msg.sentAtDate;

      final newDay = prevDate == null || !_sameDay(prevDate, date);
      if (newDay) {
        if (i > 0) items.add(const SizedBox(height: AppSpacing.xl));
        items.add(GroupChatDateDivider(label: _dateFmt.format(date)));
        items.add(const SizedBox(height: AppSpacing.base));
        prevSenderId = null;
      }

      if (msg.isSystem) {
        if (!newDay) items.add(const SizedBox(height: AppSpacing.md));
        items.add(GroupChatSystemBubble(text: msg.content ?? ''));
        prevSenderId = null;
        prevDate = date;
        continue;
      }

      final isUser = msg.senderId != null && msg.senderId == currentUserId;
      final grouped = !isUser && msg.senderId == prevSenderId;

      if (!newDay) {
        items.add(SizedBox(height: grouped ? AppSpacing.xs : AppSpacing.md));
      }

      if (isUser) {
        if (msg.isImage && msg.fileUrl != null) {
          items.add(GroupChatUserNetworkImageBubble(
            imageUrl: msg.fileUrl!,
            caption: msg.content,
          ));
        } else {
          items.add(GroupChatUserBubble(text: msg.content ?? ''));
        }
        prevSenderId = null;
      } else {
        final name = msg.senderUsername ?? 'Unknown';
        if (msg.isImage && msg.fileUrl != null) {
          items.add(GroupChatOtherNetworkImageBubble(
            name: name,
            imageUrl: msg.fileUrl!,
            showAvatar: !grouped,
            showName: !grouped,
          ));
        } else {
          items.add(GroupChatOtherBubble(
            name: name,
            text: msg.content ?? '',
            showAvatar: !grouped,
            showName: !grouped,
          ));
        }
        prevSenderId = msg.senderId;
      }
      prevDate = date;
    }

    items.add(const SizedBox(height: AppSpacing.md));

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

class _ChatEmpty extends StatelessWidget {
  const _ChatEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.message, size: 40, color: context.textTertiary),
          const SizedBox(height: AppSpacing.base),
          Text(
            'No messages yet',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Say hi to your savings group 👋',
            style:
                AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const Center(child: AppSkeleton.text(width: 90)),
        const SizedBox(height: AppSpacing.base),
        for (int i = 0; i < 6; i++) ...[
          Align(
            alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
            child: AppSkeleton(
              width: 180 + (i % 3) * 30,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ChatError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ChatError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load messages",
            style: AppTypography.bodyMedium
                .copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(
                'Retry',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
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
