import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

/// Everything about invite links lives here — the URL shape, the share copy,
/// and each share channel. Nothing else in the app should build an invite URL.
abstract class InviteService {
  /// The link a user shares. The path segment is the inviter's username, which
  /// is what the recipient's app resolves back into a friend request.
  static String linkFor(String username) =>
      '${AppConstants.inviteBaseUrl}/${Uri.encodeComponent(username)}';

  /// Parses an incoming deep link and returns the inviter's username, or null
  /// if the link isn't an invite. Accepts both the https link and the
  /// `finclar://invite/<username>` custom scheme.
  static String? usernameFromLink(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (uri.scheme == AppConstants.appScheme) {
      // finclar://invite/<username> — "invite" arrives as the host.
      if (uri.host == 'invite' && segments.isNotEmpty) return segments.first;
      if (segments.length >= 2 && segments.first == 'invite') {
        return segments[1];
      }
      return null;
    }
    final i = segments.indexOf('invite');
    if (i == -1 || i + 1 >= segments.length) return null;
    final username = segments[i + 1].trim();
    return username.isEmpty ? null : username;
  }

  static String messageFor(String username) =>
      "I'm tracking my spending on finclar — join me and let's budget together. "
      '${linkFor(username)}';

  // ─── Generic channels (any share text, e.g. a group link) ───────────────────

  static Future<void> shareText(String text) async {
    Log.d('[Invite] Opening native share sheet');
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Returns false when the target app isn't installed, so the caller can fall
  /// back to the generic share sheet instead of failing silently.
  static Future<bool> textToWhatsApp(String text) =>
      _launch(Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}'));

  static Future<bool> textToSms(String text) => _launch(
        // A bare `sms:` with a query is the portable form across iOS/Android.
        Uri(scheme: 'sms', queryParameters: {'body': text}),
      );

  static Future<bool> textToEmail(String text, {required String subject}) =>
      _launch(
        Uri(
          scheme: 'mailto',
          queryParameters: {'subject': subject, 'body': text},
        ),
      );

  // ─── Invite-link channels ───────────────────────────────────────────────────

  static Future<void> shareSheet(String username) =>
      shareText(messageFor(username));

  static Future<void> copyLink(String username) => copyText(linkFor(username));

  static Future<bool> shareToWhatsApp(String username) =>
      textToWhatsApp(messageFor(username));

  static Future<bool> shareToSms(String username) =>
      textToSms(messageFor(username));

  static Future<bool> shareToEmail(String username) =>
      textToEmail(messageFor(username), subject: 'Join me on finclar');

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Log.w('[Invite] Could not launch $uri — $e');
      return false;
    }
  }
}
