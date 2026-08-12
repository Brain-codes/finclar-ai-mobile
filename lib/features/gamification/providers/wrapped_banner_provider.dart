import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/storage_service.dart';

/// The recap month the home banner should advertise, or null when the banner
/// has no business being on screen.
///
/// The window straddles the month boundary: the last two days of a month
/// advertise that month, and the first two days of the next one still advertise
/// the month that just ended — so a user who opens the app on the 1st doesn't
/// miss it.
final wrappedBannerProvider =
    AsyncNotifierProvider<WrappedBannerNotifier, DateTime?>(
      WrappedBannerNotifier.new,
    );

class WrappedBannerNotifier extends AsyncNotifier<DateTime?> {
  static const int _windowDays = 2;

  @override
  Future<DateTime?> build() async {
    final period = periodFor(DateTime.now());
    if (period == null) return null;
    final dismissed = await StorageService.getWrappedBannerDismissed();
    return dismissed == periodKey(period) ? null : period;
  }

  /// `yyyy-MM` — the identity of a recap period, used as the dismissal key.
  static String periodKey(DateTime period) =>
      DateFormat('yyyy-MM').format(period);

  static DateTime? periodFor(DateTime now) {
    if (now.day <= _windowDays) {
      // First days of a new month — the month that just ended is the recap.
      return DateTime(now.year, now.month - 1);
    }
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    if (now.day > lastDay - _windowDays) return DateTime(now.year, now.month);
    return null;
  }

  Future<void> dismiss() async {
    final period = state.valueOrNull;
    if (period == null) return;
    state = const AsyncData(null);
    await StorageService.setWrappedBannerDismissed(periodKey(period));
  }
}
