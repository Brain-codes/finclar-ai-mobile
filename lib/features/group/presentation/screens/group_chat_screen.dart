import 'package:finclar_ai/app/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../data/models/group_item.dart';
import '../widgets/group_chat_bubble.dart';
import '../widgets/group_chat_input_bar.dart';
import '../widgets/group_chat_media_preview.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

class _Msg {
  final bool isUser;
  final String? sender;
  final String text;
  final String? imagePath;
  final String? imageFilePath;

  const _Msg.user(this.text)
    : isUser = true,
      sender = null,
      imagePath = null,
      imageFilePath = null;

  const _Msg.other(this.sender, this.text)
    : isUser = false,
      imagePath = null,
      imageFilePath = null;

  const _Msg.userImage(String path)
    : isUser = true,
      sender = null,
      text = '',
      imagePath = path,
      imageFilePath = null;

  const _Msg.otherImage(this.sender, String path)
    : isUser = false,
      text = '',
      imagePath = path,
      imageFilePath = null;

  _Msg.userPickedImage(String filePath, {String caption = ''})
    : isUser = true,
      sender = null,
      text = caption,
      imagePath = null,
      imageFilePath = filePath;

  bool get isImage => imagePath != null || imageFilePath != null;
  bool get isFilePick => imageFilePath != null;
}

class _Day {
  final DateTime date;
  final List<_Msg> messages;
  const _Day(this.date, this.messages);
}

// Older days loaded on scroll-to-top
List<_Day> _buildOlderDays(DateTime before) {
  DateTime daysB(int n) => before.subtract(Duration(days: n));
  return [
    _Day(daysB(5), [
      _Msg.other(
        'James Fanny',
        'Hey, anyone interested in starting a group savings?',
      ),
      _Msg.user('That\'s a great idea! I\'ve been thinking about this too'),
      _Msg.other('Sarah Collins', 'Count me in! What\'s the goal amount?'),
      _Msg.other('Martin Harvey', 'Let\'s target ₦3M by end of quarter 🎯'),
      _Msg.other('Janet Martin', 'That\'s ambitious but doable 🔥'),
    ]),
    _Day(daysB(4), [
      _Msg.other('James Fanny', 'I created the group! Sending invites now'),
      _Msg.other('Sarah Collins', 'Got mine! Accepting now ✅'),
      _Msg.user('Joined! Love the group name 😄'),
      _Msg.other(
        'Martin Harvey',
        'Everyone in? Let\'s set the contribution rules',
      ),
      _Msg.other('Janet Martin', 'Monthly contributions? Or weekly?'),
      _Msg.other('James Fanny', 'Monthly — ₦500K per person works best'),
    ]),
    _Day(daysB(3), [
      _Msg.other('Sarah Collins', 'Rules make sense to me ✅'),
      _Msg.user('Agreed! ₦500K monthly is fair for everyone'),
      _Msg.other('Martin Harvey', 'What happens if someone misses a month?'),
      _Msg.other('James Fanny', 'We\'ll handle that case by case'),
      _Msg.other(
        'Janet Martin',
        'Fair enough. Let\'s stay consistent and motivated 💪',
      ),
      _Msg.other('James Boshce', 'Can I invite a few more people?'),
      _Msg.user('The more the better! Go ahead'),
    ]),
  ];
}

List<_Day> _buildDays() {
  final now = DateTime.now();
  DateTime daysAgo(int n) => now.subtract(Duration(days: n));

  return [
    _Day(daysAgo(7), [
      _Msg.other(
        'James Fanny',
        'Hey team! Let\'s kick off this group savings goal 💪',
      ),
      _Msg.other('Sarah Collins', 'So excited! Let\'s do this together 🙌'),
      _Msg.other(
        'Martin Harvey',
        'Count me in! I\'ve already set aside ₦50,000',
      ),
      _Msg.user('Same here! Let\'s make this happen'),
      _Msg.other('Janet Martin', 'Just joined the group. Ready to contribute!'),
      _Msg.other(
        'Charles Lennox',
        'We\'ll hit that target before the deadline 🎯',
      ),
    ]),
    _Day(daysAgo(6), [
      _Msg.other(
        'James Fanny',
        'Quick reminder — first contribution deadline is Friday',
      ),
      _Msg.other('Sarah Collins', 'Already made mine this morning ✅'),
      _Msg.user('Will do it by tomorrow'),
      _Msg.other('Martin Harvey', 'Done ✅ ₦500,000 added to the group'),
      _Msg.other(
        'Janet Martin',
        'Working on it, will send by Thursday for sure',
      ),
      _Msg.user('Great, we\'re off to a strong start everyone!'),
      _Msg.other('James Fanny', 'Agreed! Let\'s keep the momentum going 💯'),
    ]),
    _Day(daysAgo(5), [
      _Msg.other(
        'Charles Lennox',
        'How\'s everyone doing with their contributions?',
      ),
      _Msg.other(
        'James Fanny',
        'Still waiting on a few people. We\'re at about 60% of target',
      ),
      _Msg.user('Just sent my contribution! ₦500,000 done ✅'),
      _Msg.other('Sarah Collins', 'Amazing! We\'re getting closer 🙌'),
      _Msg.other(
        'James Boshce',
        'Just joined the group! Happy to be part of this',
      ),
      _Msg.other('Martin Harvey', 'Welcome James! The more the merrier 🎉'),
      _Msg.other(
        'Janet Martin',
        'Made my first contribution — ₦200,000 for now, more coming soon',
      ),
      _Msg.other(
        'James Boshce',
        'Thanks everyone! Will send my contribution by end of week',
      ),
      _Msg.user(
        'Welcome James Boshce! Looking forward to hitting this goal together',
      ),
    ]),
    _Day(daysAgo(4), [
      _Msg.other(
        'James Fanny',
        'Group update: We\'re now at ₦1.5M raised! Halfway there! 🎉',
      ),
      _Msg.other(
        'James Fanny',
        'Here\'s a screenshot of the current progress 👇',
      ),
      _Msg.otherImage('James Fanny', 'assets/images/splash-2.png'),
      _Msg.other(
        'Sarah Collins',
        'That\'s incredible progress in just a few days!',
      ),
      _Msg.user('Great work everyone! Keep it going 💪'),
      _Msg.other(
        'Charles Lennox',
        'I need a little more time for my contribution, my bad',
      ),
      _Msg.other('Janet Martin', 'Take your time Charles, no rush at all'),
      _Msg.other(
        'James Boshce',
        'Added my ₦200,000! We\'re getting there slowly but surely',
      ),
      _Msg.other('Martin Harvey', 'The momentum is real! 💯'),
      _Msg.user('We should do a group call to align on the final stretch'),
      _Msg.other(
        'James Fanny',
        'Great idea! Let\'s schedule something for next week',
      ),
      _Msg.other(
        'Sarah Collins',
        '+1 on the call. Let\'s plan it out properly',
      ),
    ]),
    _Day(daysAgo(3), [
      _Msg.other(
        'Sarah Collins',
        'Good morning! Any updates on contributions?',
      ),
      _Msg.other('Martin Harvey', 'I\'m at ₦500,000 total now 💪'),
      _Msg.user('Added another ₦50,000 as a buffer — every bit helps!'),
      _Msg.other(
        'Charles Lennox',
        'I\'ll be contributing by end of day today, I promise',
      ),
      _Msg.other('Janet Martin', 'Same! Sending ₦100,000 more today'),
      _Msg.other('James Fanny', 'Awesome progress! Only ₦1M more to go 🎯'),
      _Msg.other(
        'James Boshce',
        'That\'s so close! We can definitely do this 🙌',
      ),
    ]),
    _Day(daysAgo(2), [
      _Msg.other(
        'Charles Lennox',
        'Sent my contribution! ₦200,000 in. Finally 😅',
      ),
      _Msg.other('Charles Lennox', 'Here\'s my transfer receipt 📄'),
      _Msg.otherImage('Charles Lennox', 'assets/images/GRADIENT.png'),
      _Msg.other(
        'James Fanny',
        'Yes!! Welcome to the contributor club Charles 🎊',
      ),
      _Msg.user('About time! 😄 Great to have everyone on board'),
      _Msg.other(
        'Martin Harvey',
        'Now we\'re all in! What\'s the current total?',
      ),
      _Msg.other(
        'Sarah Collins',
        'We\'re at ₦2.1M now, check the group stats!',
      ),
      _Msg.other('Janet Martin', '₦2.1M is amazing!! We\'re over halfway 🎉'),
    ]),
    _Day(daysAgo(1), [
      _Msg.other(
        'James Fanny',
        'Final push everyone! We need ₦900K more to hit target',
      ),
      _Msg.other('Sarah Collins', 'I can add another ₦100,000 this week'),
      _Msg.user('Let\'s organize a quick call to discuss the goal timeline'),
      _Msg.other('Janet Martin', 'Good idea! When works for everyone?'),
      _Msg.other('Martin Harvey', 'Thursday evening works for me'),
      _Msg.user('Thursday it is! 7PM?'),
      _Msg.other('James Fanny', 'Perfect, I\'ll set up a group call'),
      _Msg.other(
        'Charles Lennox',
        'I\'ll be there! And I\'ll have more contribution ready by then',
      ),
      _Msg.other('James Boshce', 'Count me in for the call 🙋'),
      _Msg.other('Sarah Collins', 'See everyone Thursday 🙌'),
    ]),
    _Day(now, [
      _Msg.other(
        'James Fanny',
        'Good morning team! Call is set for tonight at 7PM 🗓',
      ),
      _Msg.other(
        'Martin Harvey',
        'Ready for the call! Just added my final ₦500,000 contribution 💪',
      ),
      _Msg.other('Martin Harvey', 'Proof of payment below 👇'),
      _Msg.otherImage('Martin Harvey', 'assets/images/splash-3.png'),
      _Msg.other(
        'Sarah Collins',
        'Yes! We\'re at ₦1.5M, almost halfway to the target 🎯',
      ),
      _Msg.user('That\'s great! I\'ll add my contribution by Friday.'),
      _Msg.user('Here\'s my savings plan screenshot'),
      _Msg.userImage('assets/images/splash-2.png'),
      _Msg.other('Martin Harvey', 'Looks solid! See everyone tonight 🙌'),
    ]),
  ];
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class GroupChatScreen extends StatefulWidget {
  final GroupItem group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _listKey = GlobalKey<_ChatMessageListState>();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _listKey.currentState?.addMessage(_Msg.user(text));
    _messageController.clear();
  }

  Future<void> _handleCamera() async {
    await _pickAndSend(ImageSource.camera);
  }

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
    final result = await showGroupChatMediaPreview(
      context,
      filePath: image.path,
    );
    if (result == null || !mounted) return;
    _listKey.currentState?.addMessage(
      _Msg.userPickedImage(result.filePath, caption: result.caption),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: _ChatMessageList(key: _listKey),
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

class _ChatTopBar extends StatelessWidget {
  final GroupItem group;
  const _ChatTopBar({required this.group});

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: 32,
                  width: 48,
                  child: Stack(
                    children: [
                      AppAvatar(
                        initials: 'James Fanny',
                        size: 32,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      Positioned(
                        left: 16,
                        child: AppAvatar(
                          initials: 'Sarah Collins',
                          size: 32,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
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
                '10 friends',
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
// reverse: true  → list starts at the bottom (most recent visible on open).
// Scroll UP      → older messages; scroll to visual top triggers load-more.
// Pull DOWN hard → Clara AI card snaps in below the latest message.

class _ChatMessageList extends StatefulWidget {
  const _ChatMessageList({super.key});

  @override
  State<_ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<_ChatMessageList> {
  late final ScrollController _sc;
  late final ValueNotifier<double> _pullProgress;

  List<_Day> _days = _buildDays();
  bool _claraVisible = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  // Latches true once the user pulls past 100 % — persists through spring-back
  // so ScrollEndNotification can still read it after pixels return to 0.
  bool _crossedThreshold = false;

  // Time-gated haptics: fire every 50 ms while pulling, regardless of progress %.
  int _lastHapticMs = 0;

  static const _claraThreshold = -40.0;
  static const _loadTrigger = 80.0;
  static final _dateFmt = DateFormat('EEE, MMM d');

  @override
  void initState() {
    super.initState();
    _pullProgress = ValueNotifier(0.0);
    _sc = ScrollController();
    _sc.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_sc.hasClients) return;
    final pos = _sc.position;

    if (!_claraVisible) {
      final progress = (-pos.pixels / _claraThreshold.abs()).clamp(0.0, 1.0);
      _pullProgress.value = progress;

      if (progress > 0) {
        // Latch crossing — survives the spring-back to 0.
        if (progress >= 1.0) _crossedThreshold = true;
        // Continuous haptic tick every 50 ms during the pull.
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastHapticMs >= 50) {
          _lastHapticMs = now;
          HapticFeedback.selectionClick();
        }
      }
    }

    if (_hasMore &&
        !_loadingMore &&
        pos.maxScrollExtent > 0 &&
        pos.pixels >= pos.maxScrollExtent - _loadTrigger) {
      _loadMore();
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && !_claraVisible) {
      final shouldReveal = _crossedThreshold;
      _pullProgress.value = 0.0;
      _crossedThreshold = false;
      _lastHapticMs = 0;
      if (shouldReveal) {
        HapticFeedback.heavyImpact();
        setState(() => _claraVisible = true);
      }
    }
    return false;
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final older = _buildOlderDays(_days.first.date);
    setState(() {
      _days = [...older, ..._days];
      _loadingMore = false;
      _hasMore = false;
    });
  }

  void addMessage(_Msg msg) {
    setState(() => _days.last.messages.add(msg));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) {
        _sc.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pullProgress.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (_loadingMore) {
      items.add(const _LoadMoreIndicator());
      items.add(const SizedBox(height: AppSpacing.base));
    }

    for (int d = 0; d < _days.length; d++) {
      final day = _days[d];
      if (d > 0) items.add(const SizedBox(height: AppSpacing.xl));
      items.add(GroupChatDateDivider(label: _dateFmt.format(day.date)));
      items.add(const SizedBox(height: AppSpacing.base));

      String? prevSender;
      for (int i = 0; i < day.messages.length; i++) {
        final msg = day.messages[i];
        final grouped = !msg.isUser && msg.sender == prevSender;
        if (i > 0) {
          items.add(SizedBox(height: grouped ? AppSpacing.xs : AppSpacing.md));
        }
        if (msg.isUser) {
          if (msg.isFilePick) {
            items.add(
              GroupChatUserFileBubble(
                filePath: msg.imageFilePath!,
                caption: msg.text.isEmpty ? null : msg.text,
              ),
            );
          } else if (msg.isImage) {
            items.add(GroupChatUserImageBubble(imagePath: msg.imagePath!));
          } else {
            items.add(GroupChatUserBubble(text: msg.text));
          }
          prevSender = null;
        } else {
          if (msg.isImage) {
            items.add(
              GroupChatOtherImageBubble(
                name: msg.sender!,
                imagePath: msg.imagePath!,
                showAvatar: !grouped,
                showName: !grouped,
              ),
            );
          } else {
            items.add(
              GroupChatOtherBubble(
                name: msg.sender!,
                text: msg.text,
                showAvatar: !grouped,
                showName: !grouped,
              ),
            );
          }
          prevSender = msg.sender;
        }
      }
    }

    items.add(const SizedBox(height: AppSpacing.md));
    items.add(const GroupChatTypingBubble(name: 'Janet Martin'));

    items.add(
      ClipRect(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
          child: _claraVisible
              ? const Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.xxl,
                    top: AppSpacing.base,
                  ),
                  child: _ClaraSection(),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: ListView(
            controller: _sc,
            reverse: true,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.base,
            ),
            children: items.reversed.toList(),
          ),
        ),
        // Floating pull-to-reveal indicator — only shown while Clara is hidden.
        if (!_claraVisible)
          Positioned(
            bottom: AppSpacing.base,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _pullProgress,
              builder: (context, progress, _) {
                if (progress <= 0) return const SizedBox.shrink();
                return Center(
                  child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: _ClaraPullIndicator(progress: progress),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Clara pull indicator ─────────────────────────────────────────────────────

class _ClaraPullIndicator extends StatelessWidget {
  final double progress;
  const _ClaraPullIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;
    final iconColor = isComplete ? AppColors.primary : context.textSecondary;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2,
              color: context.surfaceMuted,
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              color: AppColors.primary,
              strokeCap: StrokeCap.round,
            ),
          ),
          Icon(AppIcons.aiFill, size: 13, color: iconColor),
        ],
      ),
    );
  }
}

// ─── Clara AI section ─────────────────────────────────────────────────────────

class _ClaraSection extends StatelessWidget {
  const _ClaraSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clara AI',
            style: AppTypography.bodySmall.copyWith(
              color: context.textQuaternary,
              fontSize: 14,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Icon(
              AppIcons.aiFill,
              size: 20,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'No Insights Yet',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Add your expenses, income, and Clara AI will start giving you smart money insights.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 400)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
