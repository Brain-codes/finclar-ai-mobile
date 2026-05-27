import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/group_item.dart';
import '../widgets/delete_friend_sheet.dart';
import '../widgets/group_friend_tile.dart';

class _Friend {
  final String name;
  final double contributedAmount;
  final double targetAmount;

  const _Friend({
    required this.name,
    required this.contributedAmount,
    required this.targetAmount,
  });
}

final _mockFriends = [
  const _Friend(name: 'James Fanny',    contributedAmount: 500000, targetAmount: 500000),
  const _Friend(name: 'Martin Harvey',  contributedAmount: 500000, targetAmount: 500000),
  const _Friend(name: 'Sarah Collins',  contributedAmount: 500000, targetAmount: 500000),
  const _Friend(name: 'Janet Martin',   contributedAmount: 200000, targetAmount: 500000),
  const _Friend(name: 'James Boshce',   contributedAmount: 200000, targetAmount: 500000),
  const _Friend(name: 'Charles Lennox', contributedAmount: 0,      targetAmount: 500000),
  const _Friend(name: 'Amara Okafor',   contributedAmount: 200000, targetAmount: 500000),
  const _Friend(name: 'Tunde Adeyemi',  contributedAmount: 200000, targetAmount: 500000),
  const _Friend(name: 'Ngozi Eze',      contributedAmount: 200000, targetAmount: 500000),
  const _Friend(name: 'Chidi Nwosu',    contributedAmount: 200000, targetAmount: 500000),
];

class GroupFriendsScreen extends StatelessWidget {
  final GroupItem group;
  const GroupFriendsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              onBack: () => context.pop(),
              title: 'Friends',
              centerTitle: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.base,
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.radiusSheet,
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.base),
                      ...List.generate(_mockFriends.length, (i) {
                        final f = _mockFriends[i];
                        return Padding(
                          padding: EdgeInsets.only(
                            top: i == 0 ? 0 : AppSpacing.base,
                          ),
                          child: GroupFriendTile(
                            name: f.name,
                            targetAmount: f.targetAmount,
                            contributedAmount: f.contributedAmount,
                            showEdit: true,
                            onDeleteTapped: () => showDeleteFriendSheet(context),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
