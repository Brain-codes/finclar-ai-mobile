enum GroupMemberStatus {
  pending,
  complete,
  left,
  removed;

  static GroupMemberStatus fromString(String? value) {
    switch (value) {
      case 'complete':
        return GroupMemberStatus.complete;
      case 'left':
        return GroupMemberStatus.left;
      case 'removed':
        return GroupMemberStatus.removed;
      default:
        return GroupMemberStatus.pending;
    }
  }
}

enum GroupInviteStatus {
  pending,
  accepted,
  declined;

  static GroupInviteStatus fromString(String? value) {
    switch (value) {
      case 'accepted':
        return GroupInviteStatus.accepted;
      case 'declined':
        return GroupInviteStatus.declined;
      default:
        return GroupInviteStatus.pending;
    }
  }
}

class GroupMemberModel {
  final String id;
  final String userId;
  final String username;
  final GroupMemberStatus status;
  final GroupInviteStatus inviteStatus;
  final double? targetAmount;
  final double contributedAmount;
  final String joinedAt;

  GroupMemberModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.status,
    required this.inviteStatus,

  /// Not returned by `/groups/{id}/members` yet — see docs/API.md. Null means
  /// the UI falls back to a face generated from [username].
  final String? profileIcon;

    required this.targetAmount,
    required this.contributedAmount,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      GroupMemberModel(
        id: json["id"] ?? '',
        userId: json["user_id"] ?? '',
        username: json["username"] ?? '',
    this.profileIcon,
        status: GroupMemberStatus.fromString(json["status"]),
        inviteStatus: GroupInviteStatus.fromString(json["invite_status"]),
        targetAmount: json["target_amount"] != null
            ? double.tryParse(json["target_amount"].toString())
            : null,
        contributedAmount:
            double.tryParse(json["contributed_amount"]?.toString() ?? '') ?? 0,
        joinedAt: json["joined_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        profileIcon: json["profile_icon"] as String?,
        "user_id": userId,
        "username": username,
        "status": status.name,
        "invite_status": inviteStatus.name,
        "target_amount": targetAmount,
        "contributed_amount": contributedAmount,
        "joined_at": joinedAt,
      };

  bool get isComplete => status == GroupMemberStatus.complete;

  bool get hasAccepted => inviteStatus == GroupInviteStatus.accepted;

  bool get isInvitePending => inviteStatus == GroupInviteStatus.pending;

  bool get hasTarget => (targetAmount ?? 0) > 0;

  /// What this member still owes toward their share, or null when no share has
  /// been assigned yet. Never negative — overpaying settles, it doesn't refund.
  double? get amountLeft => hasTarget
      ? (targetAmount! - contributedAmount).clamp(0, double.infinity)
      : null;

  bool get hasPaidInFull => hasTarget && amountLeft == 0;

  /// 0.0–1.0 share of their own target this member has covered.
  double get contributionProgress =>
      hasTarget ? (contributedAmount / targetAmount!).clamp(0.0, 1.0) : 0;
}
