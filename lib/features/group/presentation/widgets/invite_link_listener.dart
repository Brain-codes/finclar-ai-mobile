import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../auth/providers/user_profile_provider.dart';
import 'add_friend_sheet.dart';

/// Opens the add-friend sheet pre-filled when the app is launched from an
/// invite link. Mounted once inside the signed-in shell, so it can only fire
/// somewhere it makes sense to show a sheet.
class InviteLinkListener extends ConsumerStatefulWidget {
  final Widget child;
  const InviteLinkListener({super.key, required this.child});

  @override
  ConsumerState<InviteLinkListener> createState() => _InviteLinkListenerState();
}

class _InviteLinkListenerState extends ConsumerState<InviteLinkListener> {
  StreamSubscription<String>? _sub;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _sub = DeepLinkService.inviteStream.listen(_onInvite);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onInvite(String username) async {
    // A second link arriving while the sheet is open would stack sheets.
    if (_handling || !mounted) return;

    final me = ref.read(userProfileProvider).valueOrNull?.username;
    if (me != null && me.toLowerCase() == username.toLowerCase()) {
      Log.d('[Invite] Ignoring own invite link');
      return;
    }

    _handling = true;
    try {
      await showAddFriendSheet(
        context,
        mode: AddFriendMode.sendRequest,
        initialQuery: username,
      );
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
