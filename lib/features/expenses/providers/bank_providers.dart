import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../data/models/bank_model.dart';
import '../data/repositories/bank_repository.dart';
import 'expense_providers.dart';

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepository(ref.watch(apiClientProvider));
});

final availableBanksProvider = FutureProvider<List<AvailableBankModel>>((ref) {
  return ref.watch(bankRepositoryProvider).getAvailableBanks();
});

class LinkedBanksNotifier extends AsyncNotifier<List<BankModel>> {
  @override
  Future<List<BankModel>> build() => _fetch();

  Future<List<BankModel>> _fetch() =>
      ref.read(bankRepositoryProvider).getLinkedBanks();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<BankModel> link(String monoCode) async {
    final bank = await ref.read(bankRepositoryProvider).linkBank(monoCode);
    state = AsyncData([...?state.valueOrNull, bank]);
    // Pull the account's transactions into expenses right after linking.
    // A sync failure must not fail the link — the account is already connected.
    try {
      await ref.read(bankRepositoryProvider).syncBank(bank.id);
      _refreshExpenseViews();
    } catch (e) {
      Log.e('Post-link sync failed for ${bank.id}', error: e);
    }
    return bank;
  }

  Future<void> unlink(String bankId) async {
    await ref.read(bankRepositoryProvider).unlinkBank(bankId);
    state = AsyncData(
      (state.valueOrNull ?? []).where((b) => b.id != bankId).toList(),
    );
  }

  Future<void> sync(String bankId) async {
    await ref.read(bankRepositoryProvider).syncBank(bankId);
    _refreshExpenseViews();
  }

  void _refreshExpenseViews() {
    ref.invalidate(expenseListProvider);
    ref.invalidate(homeSummaryProvider);
    ref.invalidate(homeInsightProvider);
  }
}

final linkedBanksProvider =
    AsyncNotifierProvider<LinkedBanksNotifier, List<BankModel>>(
  LinkedBanksNotifier.new,
);
