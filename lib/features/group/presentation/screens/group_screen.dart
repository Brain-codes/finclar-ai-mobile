import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/group_item.dart';
import '../widgets/group_card.dart';
import '../widgets/group_empty_state.dart';

final _mockGroups = [
  GroupItem(name: 'Trip to Bali', amountSaved: '₦00.00', daysLeft: '29 days left', target: '₦1,000,000', progress: 0.0, themeColor: AppColors.primary),
  GroupItem(name: 'Wedding Ceremony', amountSaved: '₦550,000', daysLeft: '19 days left', target: '₦1,500,000.00', progress: 0.5, themeColor: AppColors.categoryShopping),
  GroupItem(name: 'Laptop', amountSaved: '₦650,000', daysLeft: '10 days left', target: '₦800,000.00', progress: 0.75, themeColor: AppColors.warning),
  GroupItem(name: 'Trip to Maldives', amountSaved: '₦350,000', daysLeft: '29 days left', target: '₦100,000.00', progress: 0.32, themeColor: AppColors.primary),
];

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final bool _hasGroups = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: _hasGroups
            ? _FilledState(onCreateGroup: _onCreateGroup)
            : _EmptyState(onCreateGroup: _onCreateGroup),
      ),
    );
  }

  void _onCreateGroup() => context.push(RouteNames.createGroup);
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _EmptyState({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: GroupEmptyState(onCreateGroup: onCreateGroup),
    );
  }
}

class _FilledState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _FilledState({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _Header(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.base,
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding + 72,
                ),
                itemCount: _mockGroups.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.base),
                itemBuilder: (context, i) {
                  final g = _mockGroups[i];
                  return GroupCard(
                    name: g.name,
                    amountSaved: g.amountSaved,
                    daysLeft: g.daysLeft,
                    target: g.target,
                    progress: g.progress,
                    themeColor: g.themeColor,
                    onTap: () => context.push(RouteNames.groupDetail, extra: g),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.screenPadding,
          child: GestureDetector(
            onTap: onCreateGroup,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.add, size: 24, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Group',
            style: AppTypography.headingLarge.copyWith(
              color: context.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteNames.createGroup),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(AppIcons.add, size: 20, color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
