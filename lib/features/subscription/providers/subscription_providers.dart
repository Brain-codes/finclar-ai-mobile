import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../data/models/plan_model.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(apiClientProvider));
});

final subscriptionPlansProvider =
    FutureProvider<PlansResponseModel>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).getPlans();
});

class SubscriptionNotifier extends AsyncNotifier<SubscriptionModel?> {
  SubscriptionRepository get _repo => ref.read(subscriptionRepositoryProvider);

  @override
  Future<SubscriptionModel?> build() => _repo.getMySubscription();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.getMySubscription);
  }

  Future<SubscriptionModel> verifyCheckout({
    required String reference,
    required PlanCode planCode,
  }) async {
    final verified = await _repo.verifyCheckout(
      reference: reference,
      planCode: planCode,
    );
    state = AsyncData(verified);
    return verified;
  }

  Future<SubscriptionModel> cancel() async {
    final updated = await _repo.cancel();
    state = AsyncData(updated);
    return updated;
  }

  Future<SubscriptionModel> resume() async {
    final updated = await _repo.resume();
    state = AsyncData(updated);
    return updated;
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionModel?>(
  SubscriptionNotifier.new,
);

final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).valueOrNull?.isActive ?? false;
});
