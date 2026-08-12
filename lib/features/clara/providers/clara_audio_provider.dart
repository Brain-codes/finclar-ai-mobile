import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';

/// Whether Clara plays a chime when a reply arrives. Defaults to on.
class ClaraAudioNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(AppConstants.claraAudioEnabledKey);
      if (saved != null) state = saved;
    } catch (e) {
      Log.w('Failed to load Clara audio preference', error: e);
    }
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.claraAudioEnabledKey, value);
    } catch (e) {
      Log.w('Failed to save Clara audio preference', error: e);
    }
  }
}

final claraAudioEnabledProvider =
    NotifierProvider<ClaraAudioNotifier, bool>(ClaraAudioNotifier.new);
