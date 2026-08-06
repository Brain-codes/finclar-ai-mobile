import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../data/models/challenge_model.dart';
import '../data/repositories/challenge_repository.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(ref.watch(apiClientProvider));
});

/// All of the user's challenges. The list is small (one per type today), so it
/// walks every page rather than paging in the UI.
final challengesProvider =
    AsyncNotifierProvider<ChallengeListNotifier, List<ChallengeModel>>(
      ChallengeListNotifier.new,
    );

class ChallengeListNotifier extends AsyncNotifier<List<ChallengeModel>> {
  ChallengeRepository get _repo => ref.read(challengeRepositoryProvider);

  @override
  Future<List<ChallengeModel>> build() => _repo.getChallenges();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getChallenges);
  }

  Future<ChallengeModel> create({
    ChallengeType type = ChallengeType.fridaySavings,
    String? name,
    double? weeklyTarget,
    double? overallTarget,
    String? targetCategoryId,
    DateTime? endDate,
  }) async {
    final created = await _repo.createChallenge(
      type: type,
      name: name,
      weeklyTarget: weeklyTarget,
      overallTarget: overallTarget,
      targetCategoryId: targetCategoryId,
      endDate: endDate,
    );
    await refresh();
    return created;
  }

  Future<ChallengeModel> edit(
    String id, {
    String? name,
    double? weeklyTarget,
    double? overallTarget,
    DateTime? endDate,
  }) async {
    final updated = await _repo.updateChallenge(
      id,
      name: name,
      weeklyTarget: weeklyTarget,
      overallTarget: overallTarget,
      endDate: endDate,
    );
    await refresh();
    return updated;
  }

  /// QA only. Fires the same badge and push logic as a real entry, so badges
  /// and entries are refetched exactly as [recordEntry] does.
  Future<void> simulateStreak(String id, int weeks) async {
    await _repo.simulateStreak(id, weeks);
    await refresh();
    ref.invalidate(challengeEntriesProvider(id));
    ref.invalidate(myBadgesProvider);
  }

  Future<void> sendTestReminder(String id) => _repo.sendTestReminder(id);

  Future<void> cancel(String id) async {
    await _repo.cancelChallenge(id);
    await refresh();
  }

  /// Recording an entry moves the streak and can earn a badge, so both the
  /// challenge list and the user's badges are refetched.
  Future<ChallengeEntryModel> recordEntry(
    String challengeId, {
    double? amount,
    String? note,
    File? receipt,
  }) async {
    final entry = await _repo.recordEntry(
      challengeId,
      amount: amount,
      note: note,
      receipt: receipt,
    );
    await refresh();
    ref.invalidate(challengeEntriesProvider(challengeId));
    ref.invalidate(myBadgesProvider);
    return entry;
  }
}

final challengeEntriesProvider =
    FutureProvider.family<List<ChallengeEntryModel>, String>((
      ref,
      challengeId,
    ) {
      return ref.watch(challengeRepositoryProvider).getEntries(challengeId);
    });

/// Every badge that exists — used to show locked/unlocked state alongside
/// [myBadgesProvider].
final badgeCatalogProvider = FutureProvider<List<BadgeModel>>((ref) {
  return ref.watch(challengeRepositoryProvider).getBadgeCatalog();
});

final myBadgesProvider = FutureProvider<List<UserBadgeModel>>((ref) {
  return ref.watch(challengeRepositoryProvider).getMyBadges();
});
