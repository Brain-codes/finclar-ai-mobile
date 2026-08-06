import 'dart:async';
import 'package:app_links/app_links.dart';
import 'auth_state_service.dart';
import 'invite_service.dart';
import 'logger_service.dart';
import 'storage_service.dart';

/// Receives incoming links (cold start and while running) and turns them into
/// app intent. Only invite links are handled today.
///
/// Nothing here navigates directly — it stores the intent and notifies, so the
/// UI layer decides when it is safe to act (e.g. not mid-onboarding).
class DeepLinkService {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  /// Fires with an inviter's username once the app is ready to act on it.
  static final _inviteController = StreamController<String>.broadcast();
  static Stream<String> get inviteStream => _inviteController.stream;

  static Future<void> init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await _handle(initial);
    } catch (e) {
      Log.w('[DeepLink] Could not read initial link — $e');
    }

    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (Object e) => Log.e('[DeepLink] Link stream error', error: e),
    );
  }

  static Future<void> _handle(Uri uri) async {
    Log.d('[DeepLink] Received $uri');
    final username = InviteService.usernameFromLink(uri);
    if (username == null) {
      Log.w('[DeepLink] Not an invite link — ignoring');
      return;
    }

    if (!authStateService.isLoggedIn) {
      // Park it: the user has to authenticate before we can send a request.
      Log.i('[DeepLink] Invite from "$username" parked until login');
      await StorageService.savePendingInvite(username);
      return;
    }
    _inviteController.add(username);
  }

  /// Replays an invite that arrived while logged out. Called once after a
  /// successful login/registration.
  static Future<void> replayPendingInvite() async {
    final username = await StorageService.getPendingInvite();
    if (username == null || username.isEmpty) return;
    await StorageService.clearPendingInvite();
    Log.i('[DeepLink] Replaying parked invite from "$username"');
    _inviteController.add(username);
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
