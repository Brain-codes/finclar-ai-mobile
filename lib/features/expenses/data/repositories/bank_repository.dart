import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/bank_model.dart';

class BankRepository {
  final ApiClient _api;

  BankRepository(this._api);

  Future<List<BankModel>> getLinkedBanks() async {
    return _api.getAllPaginated<BankModel>(
      ApiEndpoints.banks,
      fromItem: BankModel.fromJson,
    );
  }

  Future<List<AvailableBankModel>> getAvailableBanks() async {
    return _api.getAllPaginated<AvailableBankModel>(
      ApiEndpoints.banksAvailable,
      fromItem: AvailableBankModel.fromJson,
    );
  }

  Future<BankModel> linkBank(String monoCode) async {
    final response = await _api.post<BankModel>(
      ApiEndpoints.bankLink,
      body: {'code': monoCode},
      fromData: (data) => BankModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> syncBank(String bankId) async {
    await _api.post<Map<String, dynamic>>(
      ApiEndpoints.bankSync(bankId),
      fromData: (data) => data as Map<String, dynamic>,
    );
    Log.d('Bank synced: $bankId');
  }

  Future<void> unlinkBank(String bankId) async {
    await _api.delete<Map<String, dynamic>>(
      ApiEndpoints.bank(bankId),
      fromData: (data) => data as Map<String, dynamic>,
    );
    Log.d('Bank unlinked: $bankId');
  }
}
