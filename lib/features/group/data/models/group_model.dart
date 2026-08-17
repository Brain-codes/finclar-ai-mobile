import 'dart:convert';
import 'group_member_model.dart';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));
String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  final String id;
  final String name;
  final double targetAmount;
  final String endDate;
  final String ownerId;
  final String createdAt;
  final double totalRaised;
  final double balance;
  final int daysLeft;
  final int memberCount;
  final double progressPercent;
  final String shareableLink;

  /// Contributed so far across all members.
  final double amountPaid;

  /// Still outstanding against the group target.
  final double amountLeft;

  /// Sum of every member's individual target. May differ from [targetAmount]
  /// when shares haven't been fully allocated.
  final double amountAssigned;

  /// The current user's own invite status for this group. `pending` means they
  /// were invited and haven't yet accepted or declined.
  final GroupInviteStatus inviteStatus;

  final List<GroupMemberModel> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.endDate,
    required this.ownerId,
    required this.createdAt,
    required this.totalRaised,
    required this.balance,
    required this.daysLeft,
    required this.memberCount,
    required this.progressPercent,
    required this.shareableLink,
    required this.amountPaid,
    required this.amountLeft,
    required this.amountAssigned,
    this.inviteStatus = GroupInviteStatus.accepted,
    this.members = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        targetAmount:
            double.tryParse(json["target_amount"]?.toString() ?? '') ?? 0,
        endDate: json["end_date"] ?? '',
        ownerId: json["owner_id"] ?? '',
        createdAt: json["created_at"] ?? '',
        totalRaised:
            double.tryParse(json["total_raised"]?.toString() ?? '') ?? 0,
        balance: double.tryParse(json["balance"]?.toString() ?? '') ?? 0,
        daysLeft: json["days_left"] ?? 0,
        memberCount: json["member_count"] ?? 0,
        progressPercent:
            double.tryParse(json["progress_percent"]?.toString() ?? '') ?? 0,
        shareableLink: json["shareable_link"] ?? '',
        amountPaid: double.tryParse(json["amount_paid"]?.toString() ?? '') ?? 0,
        amountLeft: double.tryParse(json["amount_left"]?.toString() ?? '') ?? 0,
        amountAssigned:
            double.tryParse(json["amount_assigned"]?.toString() ?? '') ?? 0,
        inviteStatus: GroupInviteStatus.fromString(json["invite_status"]),
        members: json["members"] != null
            ? List<GroupMemberModel>.from(
                (json["members"] as List).map(
                  (e) => GroupMemberModel.fromJson(e as Map<String, dynamic>),
                ),
              )
            : const [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "target_amount": targetAmount,
        "end_date": endDate,
        "owner_id": ownerId,
        "created_at": createdAt,
        "total_raised": totalRaised,
        "balance": balance,
        "days_left": daysLeft,
        "member_count": memberCount,
        "progress_percent": progressPercent,
        "shareable_link": shareableLink,
        "amount_paid": amountPaid,
        "amount_left": amountLeft,
        "amount_assigned": amountAssigned,
        "invite_status": inviteStatus.name,
      };

  /// 0.0–1.0 progress for the segmented bar (progressPercent is 0–100).
  double get progress {
    if (progressPercent > 0) return (progressPercent / 100).clamp(0.0, 1.0);
    if (targetAmount <= 0) return 0;
    return (totalRaised / targetAmount).clamp(0.0, 1.0);
  }

  String get daysLeftLabel => daysLeft == 1 ? '1 day left' : '$daysLeft days left';

  /// True when the current user was invited and hasn't yet responded.
  bool get isInvitePending => inviteStatus == GroupInviteStatus.pending;

  /// Members visible to [currentUserId]: departed members are never shown,
  /// and pending (unaccepted) invites are only visible to the owner.
  List<GroupMemberModel> visibleMembers(String? currentUserId) {
    final isOwner = ownerId == currentUserId;
    return members
        .where((m) =>
            m.status != GroupMemberStatus.left &&
            m.status != GroupMemberStatus.removed &&
            (isOwner || m.hasAccepted))
        .toList();
  }

  /// Friend count visible to [currentUserId] — see [visibleMembers].
  int visibleMemberCount(String? currentUserId) =>
      visibleMembers(currentUserId).length;

  GroupModel copyWith({List<GroupMemberModel>? members}) => GroupModel(
        id: id,
        name: name,
        targetAmount: targetAmount,
        endDate: endDate,
        ownerId: ownerId,
        createdAt: createdAt,
        totalRaised: totalRaised,
        balance: balance,
        daysLeft: daysLeft,
        memberCount: memberCount,
        progressPercent: progressPercent,
        shareableLink: shareableLink,
        amountPaid: amountPaid,
        amountLeft: amountLeft,
        amountAssigned: amountAssigned,
        inviteStatus: inviteStatus,
        members: members ?? this.members,
      );
}
