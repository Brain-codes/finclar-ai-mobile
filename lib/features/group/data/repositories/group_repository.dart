import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/image_compression_service.dart';
import '../../../../core/services/logger_service.dart';
import '../models/group_member_model.dart';
import '../models/group_message_model.dart';
import '../models/group_model.dart';
import '../models/savings_entry_model.dart';

class GroupRepository {
  final ApiClient _api;

  GroupRepository(this._api);

  // ─── Groups ────────────────────────────────────────────────────────────────

  Future<List<GroupModel>> getGroups() async {
    Log.api('GET', ApiEndpoints.groups);
    return _api.getAllPaginated<GroupModel>(
      ApiEndpoints.groups,
      fromItem: GroupModel.fromJson,
    );
  }

  Future<GroupModel> getGroup(String id) async {
    Log.api('GET', ApiEndpoints.group(id));
    final response = await _api.get<GroupModel>(
      ApiEndpoints.group(id),
      fromData: (data) => GroupModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<GroupModel> createGroup({
    required String name,
    required double targetAmount,
    required DateTime endDate,
    List<String> memberIds = const [],
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'target_amount': targetAmount,
      'end_date': _dateOnly(endDate),
      'member_ids': memberIds,
    };
    Log.api('POST', ApiEndpoints.groups, body: body);
    final response = await _api.post<GroupModel>(
      ApiEndpoints.groups,
      body: body,
      fromData: (data) => GroupModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<GroupModel> updateGroup(
    String id, {
    String? name,
    double? targetAmount,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (targetAmount != null) body['target_amount'] = targetAmount;
    if (endDate != null) body['end_date'] = _dateOnly(endDate);
    Log.api('PUT', ApiEndpoints.group(id), body: body);
    final response = await _api.put<GroupModel>(
      ApiEndpoints.group(id),
      body: body,
      fromData: (data) => GroupModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> deleteGroup(String id) async {
    Log.api('DELETE', ApiEndpoints.group(id));
    await _api.delete<void>(ApiEndpoints.group(id));
  }

  Future<void> leaveGroup(String id) async {
    Log.api('POST', ApiEndpoints.groupLeave(id));
    await _api.post<void>(ApiEndpoints.groupLeave(id));
  }

  Future<void> respondToInvite(String id, {required bool accept}) async {
    final body = {'response': accept ? 'accepted' : 'declined'};
    Log.api('POST', ApiEndpoints.groupInvite(id), body: body);
    await _api.post<void>(ApiEndpoints.groupInvite(id), body: body);
  }

  Future<String> getShareLink(String id) async {
    Log.api('GET', ApiEndpoints.groupShare(id));
    final response = await _api.get<String>(
      ApiEndpoints.groupShare(id),
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          return (data['link'] ?? data['share_link'] ?? data['url'] ?? '')
              .toString();
        }
        return data?.toString() ?? '';
      },
    );
    return response.data ?? '';
  }

  // ─── Members ─────────────────────────────────────────────────────────────

  // NOTE: endpoint is planned, not yet live — see docs/API.md. The owner adds
  // an existing finclar user to the group; they land as invite_status: pending.
  Future<GroupMemberModel> addMember(String groupId, String recipientId) async {
    final body = {'recipient_id': recipientId};
    Log.api('POST', ApiEndpoints.groupMembers(groupId), body: body);
    final response = await _api.post<GroupMemberModel>(
      ApiEndpoints.groupMembers(groupId),
      body: body,
      fromData: (data) =>
          GroupMemberModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<GroupMemberModel> updateMember(
    String groupId,
    String memberId, {
    required double targetAmount,
  }) async {
    Log.api('PUT', ApiEndpoints.groupMember(groupId, memberId));
    final response = await _api.put<GroupMemberModel>(
      ApiEndpoints.groupMember(groupId, memberId),
      body: {'target_amount': targetAmount},
      fromData: (data) =>
          GroupMemberModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> removeMember(
    String groupId,
    String memberId, {
    required RedistributionChoice redistribution,
  }) async {
    Log.api('DELETE', ApiEndpoints.groupMember(groupId, memberId));
    await _api.delete<void>(
      ApiEndpoints.groupMember(groupId, memberId),
      queryParams: {'redistribution': redistribution.value},
    );
  }

  // ─── Savings ─────────────────────────────────────────────────────────────

  Future<List<SavingsEntryModel>> getSavings(String groupId) async {
    Log.api('GET', ApiEndpoints.groupSavings(groupId));
    return _api.getAllPaginated<SavingsEntryModel>(
      ApiEndpoints.groupSavings(groupId),
      fromItem: SavingsEntryModel.fromJson,
    );
  }

  Future<SavingsEntryModel> recordSavings(
    String groupId, {
    required double amount,
    String? note,
    File? receipt,
  }) async {
    final map = <String, dynamic>{'amount': amount};
    if (note != null && note.isNotEmpty) map['note'] = note;
    if (receipt != null) {
      map['receipt'] = await ImageCompressionService.multipart(receipt);
    }
    final formData = FormData.fromMap(map);
    Log.api('POST', ApiEndpoints.groupSavings(groupId));
    final response = await _api.uploadFile<SavingsEntryModel>(
      ApiEndpoints.groupSavings(groupId),
      formData: formData,
      fromData: (data) =>
          SavingsEntryModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  // ─── Messages ────────────────────────────────────────────────────────────

  Future<List<GroupMessageModel>> getMessages(
    String groupId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    Log.api('GET', ApiEndpoints.groupMessages(groupId),
        body: {'page': page, 'page_size': pageSize});
    final response = await _api.get<List<GroupMessageModel>>(
      ApiEndpoints.groupMessages(groupId),
      queryParams: {'page': page, 'page_size': pageSize},
      fromData: (data) => (data as List)
          .map((e) => GroupMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }

  Future<GroupMessageModel> sendMessage(
    String groupId,
    String content,
  ) async {
    Log.api('POST', ApiEndpoints.groupMessages(groupId));
    final response = await _api.post<GroupMessageModel>(
      ApiEndpoints.groupMessages(groupId),
      body: {'content': content},
      fromData: (data) =>
          GroupMessageModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<GroupMessageModel> sendAttachment(
    String groupId, {
    required File file,
    double? recordAmount,
  }) async {
    final map = <String, dynamic>{
      'file': await ImageCompressionService.multipart(file),
    };
    if (recordAmount != null) map['record_amount'] = recordAmount;
    final formData = FormData.fromMap(map);
    Log.api('POST', ApiEndpoints.groupMessageAttachment(groupId));
    final response = await _api.uploadFile<GroupMessageModel>(
      ApiEndpoints.groupMessageAttachment(groupId),
      formData: formData,
      fromData: (data) =>
          GroupMessageModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
