import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import '../data/models/user_model.dart';
import 'auth_repository_provider.dart';

class UserProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final token = await StorageService.getAccessToken();
    if (token == null) return null;

    final cached = await _readCache();
    if (cached != null) {
      _refreshInBackground();
      return cached;
    }

    return _fetchAndCache();
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetchAndCache());
    } on AppException catch (e) {
      Log.e('Failed to fetch user profile', error: e);
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Patches the profile and folds the response straight into state — no
  /// refetch needed, `PATCH /user/me` returns the full updated user.
  Future<UserModel> updateProfile({
    String? username,
    String? preferredName,
    String? defaultCurrency,
    String? profileIcon,
  }) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(
          username: username,
          preferredName: preferredName,
          defaultCurrency: defaultCurrency,
          profileIcon: profileIcon,
        );
    await StorageService.saveCachedUser(userModelToJson(updated));
    state = AsyncData(updated);
    return updated;
  }

  Future<UserModel> _fetchAndCache() async {
    final user = await ref.read(authRepositoryProvider).getUserProfile();
    await StorageService.saveCachedUser(userModelToJson(user));
    Analytics.identify(
      id: user.id,
      currency: user.defaultCurrency,
      isEmailVerified: user.isEmailVerified,
    );
    return user;
  }

  Future<void> _refreshInBackground() async {
    try {
      state = AsyncData(await _fetchAndCache());
    } on AppException catch (e) {
      Log.w('Background user refresh failed, keeping cached profile', error: e);
    }
  }

  Future<UserModel?> _readCache() async {
    final json = await StorageService.getCachedUser();
    if (json == null) return null;
    try {
      return userModelFromJson(json);
    } catch (e) {
      Log.w('Failed to decode cached user', error: e);
      await StorageService.clearCachedUser();
      return null;
    }
  }

  void clear() {
    state = const AsyncData(null);
    StorageService.clearCachedUser();
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel?>(
  UserProfileNotifier.new,
);
