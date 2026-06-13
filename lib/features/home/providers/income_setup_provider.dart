import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/logger_service.dart';
import '../data/models/income_model.dart';
import '../data/models/income_source_model.dart';
import '../data/repositories/income_repository.dart';

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepository(ref.watch(apiClientProvider));
});

// ─── Sources ──────────────────────────────────────────────────────────────────

class IncomeSourcesNotifier
    extends AsyncNotifier<List<IncomeSourceModel>> {
  @override
  Future<List<IncomeSourceModel>> build() async {
    return ref.read(incomeRepositoryProvider).getSources();
  }

  Future<IncomeSourceModel> addSource(String name) async {
    final newSource =
        await ref.read(incomeRepositoryProvider).createCustomSource(name);
    state = AsyncData([...state.valueOrNull ?? [], newSource]);
    return newSource;
  }
}

final incomeSourcesProvider = AsyncNotifierProvider<IncomeSourcesNotifier,
    List<IncomeSourceModel>>(IncomeSourcesNotifier.new);

// ─── Income ───────────────────────────────────────────────────────────────────

class IncomeNotifier extends AsyncNotifier<IncomeModel?> {
  @override
  Future<IncomeModel?> build() async {
    Log.d('[incomeProvider] build() called — fetching income from API');
    final result = await ref.read(incomeRepositoryProvider).getIncome();
    Log.d('[incomeProvider] build() complete — income=${result?.toJson()}');
    return result;
  }

  Future<void> create({
    required double amount,
    required String sourceId,
    required String reoccurrence,
    required String startDate,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(incomeRepositoryProvider).createIncome(
            amount: amount,
            sourceId: sourceId,
            reoccurrence: reoccurrence,
            startDate: startDate,
            note: note,
          ),
    );
  }

  Future<void> save({
    double? amount,
    String? sourceId,
    String? reoccurrence,
    String? startDate,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(incomeRepositoryProvider).updateIncome(
            amount: amount,
            sourceId: sourceId,
            reoccurrence: reoccurrence,
            startDate: startDate,
            note: note,
          ),
    );
  }
}

final incomeProvider =
    AsyncNotifierProvider<IncomeNotifier, IncomeModel?>(IncomeNotifier.new);
