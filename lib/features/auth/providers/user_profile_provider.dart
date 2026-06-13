import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../data/models/user_model.dart';
import 'auth_repository_provider.dart';

class UserProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async => null;

  Future<void> fetch() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).getUserProfile();
      state = AsyncData(user);
    } on AppException catch (e) {
      Log.e('Failed to fetch user profile', error: e);
      state = AsyncError(e, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel?>(
  UserProfileNotifier.new,
);
