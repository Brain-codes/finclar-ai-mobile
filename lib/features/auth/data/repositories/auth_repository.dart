import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/token_pair_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<void> register({
    required String email,
    required String username,
    required String passcode,
    String defaultCurrency = 'USD',
  }) async {
    Log.api('POST', ApiEndpoints.register, body: {'email': email, 'username': username});
    await _api.post<void>(
      ApiEndpoints.register,
      body: {
        'email': email,
        'username': username,
        'passcode': passcode,
        'default_currency': defaultCurrency,
      },
    );
  }

  Future<TokenPairModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    Log.api('POST', ApiEndpoints.verifyEmail, body: {'email': email});
    final response = await _api.post<TokenPairModel>(
      ApiEndpoints.verifyEmail,
      body: {'email': email, 'code': code},
      fromData: (data) => TokenPairModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<TokenPairModel> login({
    required String email,
    required String passcode,
  }) async {
    Log.api('POST', ApiEndpoints.login, body: {'email': email});
    final response = await _api.post<TokenPairModel>(
      ApiEndpoints.login,
      body: {'email': email, 'passcode': passcode},
      fromData: (data) => TokenPairModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> resendOtp({required String email}) async {
    Log.api('POST', ApiEndpoints.resendOtp, body: {'email': email});
    await _api.post<void>(
      ApiEndpoints.resendOtp,
      body: {'email': email},
    );
  }

  Future<UserModel> getUserProfile() async {
    Log.api('GET', ApiEndpoints.me);
    final response = await _api.get<UserModel>(
      ApiEndpoints.me,
      fromData: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> setGoals(List<String> goals) async {
    Log.api('POST', ApiEndpoints.onboardingGoals, body: {'goals': goals});
    await _api.post<void>(
      ApiEndpoints.onboardingGoals,
      body: {'goals': goals},
    );
  }

  Future<void> logout() async {
    Log.api('POST', ApiEndpoints.logout);
    await _api.post<void>(ApiEndpoints.logout);
  }

  Future<void> logoutAll() async {
    Log.api('POST', ApiEndpoints.logoutAll);
    await _api.post<void>(ApiEndpoints.logoutAll);
  }

  Future<void> forgotPasscode({required String email}) async {
    Log.api('POST', ApiEndpoints.forgotPasscode, body: {'email': email});
    await _api.post<void>(
      ApiEndpoints.forgotPasscode,
      body: {'email': email},
    );
  }

  Future<TokenPairModel> resetPasscode({
    required String email,
    required String code,
    required String newPasscode,
  }) async {
    Log.api('POST', ApiEndpoints.resetPasscode, body: {'email': email});
    final response = await _api.post<TokenPairModel>(
      ApiEndpoints.resetPasscode,
      body: {'email': email, 'code': code, 'new_passcode': newPasscode},
      fromData: (data) => TokenPairModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<TokenPairModel> refreshToken({required String refreshToken}) async {
    Log.api('POST', ApiEndpoints.refreshToken);
    final response = await _api.post<TokenPairModel>(
      ApiEndpoints.refreshToken,
      body: {'refresh_token': refreshToken},
      fromData: (data) => TokenPairModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<bool> checkUsernameAvailable(String username) async {
    Log.api('GET', ApiEndpoints.checkUsername, body: {'username': username});
    final response = await _api.get<bool>(
      ApiEndpoints.checkUsername,
      queryParams: {'username': username},
      fromData: (data) => (data as Map<String, dynamic>)['available'] as bool,
    );
    return response.data ?? false;
  }
}
