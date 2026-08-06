import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/image_compression_service.dart';
import '../../../../core/services/logger_service.dart';
import '../models/challenge_model.dart';

class ChallengeRepository {
  final ApiClient _api;

  ChallengeRepository(this._api);

  Future<List<ChallengeModel>> getChallenges({ChallengeStatus? status}) async {
    final query = <String, dynamic>{'status': ?status?.value};
    Log.api('GET', ApiEndpoints.challenges, body: query);
    return _api.getAllPaginated<ChallengeModel>(
      ApiEndpoints.challenges,
      queryParams: query.isEmpty ? null : query,
      fromItem: ChallengeModel.fromJson,
    );
  }

  Future<ChallengeModel> getChallenge(String id) async {
    Log.api('GET', ApiEndpoints.challenge(id));
    final response = await _api.get<ChallengeModel>(
      ApiEndpoints.challenge(id),
      fromData: (data) => ChallengeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Every field is optional — the backend defaults [type] to `friday_savings`,
  /// names it "Friday Savings Challenge" and dates it itself when omitted.
  /// [targetCategoryId] only applies to [ChallengeType.budgetCategory].
  Future<ChallengeModel> createChallenge({
    ChallengeType type = ChallengeType.fridaySavings,
    String? name,
    double? weeklyTarget,
    double? overallTarget,
    String? targetCategoryId,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{
      'type': type.value,
      'name': ?name,
      'weekly_target': ?weeklyTarget,
      'overall_target': ?overallTarget,
      'target_category_id': ?targetCategoryId,
      'end_date': ?_toDateOnly(endDate),
    };
    Log.api('POST', ApiEndpoints.challenges, body: body);
    final response = await _api.post<ChallengeModel>(
      ApiEndpoints.challenges,
      body: body,
      fromData: (data) => ChallengeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ChallengeModel> updateChallenge(
    String id, {
    String? name,
    double? weeklyTarget,
    double? overallTarget,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'weekly_target': ?weeklyTarget,
      'overall_target': ?overallTarget,
      'end_date': ?_toDateOnly(endDate),
    };
    Log.api('PUT', ApiEndpoints.challenge(id), body: body);
    final response = await _api.put<ChallengeModel>(
      ApiEndpoints.challenge(id),
      body: body,
      fromData: (data) => ChallengeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> cancelChallenge(String id) async {
    Log.api('DELETE', ApiEndpoints.challenge(id));
    await _api.delete<void>(ApiEndpoints.challenge(id));
  }

  Future<List<ChallengeEntryModel>> getEntries(String challengeId) async {
    Log.api('GET', ApiEndpoints.challengeEntries(challengeId));
    return _api.getAllPaginated<ChallengeEntryModel>(
      ApiEndpoints.challengeEntries(challengeId),
      fromItem: ChallengeEntryModel.fromJson,
    );
  }

  /// [receipt] is what makes an entry `evidence_backed` rather than
  /// `self_reported` — the backend decides the level from its presence.
  Future<ChallengeEntryModel> recordEntry(
    String challengeId, {
    double? amount,
    String? note,
    File? receipt,
  }) async {
    final formData = FormData.fromMap({
      if (amount != null) 'amount': amount.toString(),
      if (note != null && note.isNotEmpty) 'note': note,
      if (receipt != null)
        'receipt': await ImageCompressionService.multipart(receipt),
    });
    Log.api('POST', ApiEndpoints.challengeEntries(challengeId));
    final response = await _api.uploadFile<ChallengeEntryModel>(
      ApiEndpoints.challengeEntries(challengeId),
      formData: formData,
      fromData: (data) =>
          ChallengeEntryModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Backend QA helper. Jumps the streak to [weeks] and fires the same badge
  /// and push logic a real entry would, so badge states can be tested without
  /// waiting weeks of real Fridays.
  Future<ChallengeModel> simulateStreak(String id, int weeks) async {
    final endpoint = ApiEndpoints.challengeSimulateStreak(id, weeks);
    Log.api('POST', endpoint);
    final response = await _api.post<ChallengeModel>(
      endpoint,
      fromData: (data) => ChallengeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> sendTestReminder(String id) async {
    Log.api('POST', ApiEndpoints.challengeTestReminder(id));
    await _api.post<void>(ApiEndpoints.challengeTestReminder(id));
  }

  Future<List<BadgeModel>> getBadgeCatalog() async {
    Log.api('GET', ApiEndpoints.challengeBadgeCatalog);
    final response = await _api.get<List<BadgeModel>>(
      ApiEndpoints.challengeBadgeCatalog,
      fromData: (data) => (data as List)
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }

  Future<List<UserBadgeModel>> getMyBadges() async {
    Log.api('GET', ApiEndpoints.challengeBadgesMine);
    final response = await _api.get<List<UserBadgeModel>>(
      ApiEndpoints.challengeBadgesMine,
      fromData: (data) => (data as List)
          .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }
}

/// The API takes `end_date` as a bare `YYYY-MM-DD`, not a full timestamp.
String? _toDateOnly(DateTime? date) => date?.toIso8601String().split('T').first;
