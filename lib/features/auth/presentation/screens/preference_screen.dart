import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/financial_goal_model.dart';
import '../../providers/preference_provider.dart';

// ─── Visual metadata, keyed by backend goal `key` ─────────────────────────────

class _GoalVisual {
  final IconData icon;
  final Color colorFill;
  const _GoalVisual(this.icon, this.colorFill);
}

const _goalVisuals = <String, _GoalVisual>{
  'smart_money_saving': _GoalVisual(AppIcons.wallet, AppColors.categoryTransport),
  'track_my_spending': _GoalVisual(AppIcons.chart, AppColors.categoryShopping),
  'stick_to_a_budget': _GoalVisual(AppIcons.budget, AppColors.primary),
  'feel_more_in_control': _GoalVisual(AppIcons.briefcase, AppColors.success),
};

const _fallbackVisual = _GoalVisual(AppIcons.target, AppColors.primary);

// ─── Screen ───────────────────────────────────────────────────────────────────

class PreferenceScreen extends ConsumerStatefulWidget {
  const PreferenceScreen({super.key});

  @override
  ConsumerState<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  String? _selectedId;

  Future<void> _onContinue() async {
    if (_selectedId == null) return;
    await ref.read(preferenceProvider.notifier).saveGoals([_selectedId!]);
  }

  Future<void> _onSkip() async {
    await ref.read(preferenceProvider.notifier).skipGoals();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceProvider);
    final goalsAsync = ref.watch(goalsProvider);

    ref.listen(preferenceProvider, (_, next) {
      if (next.snackbarError != null) {
        AppSnackbar.error(context, next.snackbarError!);
        ref.read(preferenceProvider.notifier).clearSnackbarError();
      }
    });

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar (no step indicator, no back — terminal onboarding) ──
                const SizedBox(height: AppSpacing.base),

                // ── Scrollable content ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),

                        AppScreenHeader(
                          title: AppStrings.whatDoYouWantHelpWith,
                          subtitle: AppStrings.chooseWhatMattersMost,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Preference cards
                        goalsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xxl),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, _) => Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xl),
                            child: AppButton(
                              label: AppStrings.retry,
                              variant: AppButtonVariant.outline,
                              onTap: () => ref.invalidate(goalsProvider),
                            ),
                          ),
                          data: (goals) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(goals.length, (i) {
                              final goal = goals[i];
                              final selected = _selectedId == goal.id;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      i < goals.length - 1 ? AppSpacing.sm : 0,
                                ),
                                child: _PreferenceCard(
                                  goal: goal,
                                  selected: selected,
                                  onTap: () =>
                                      setState(() => _selectedId = goal.id),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // ── Bottom CTA ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.base,
                  ),
                  child: Column(
                    children: [
                      AppButton(
                        label: AppStrings.continueText,
                        onTap: (_selectedId == null || state.isLoading)
                            ? null
                            : _onContinue,
                        isLoading: state.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      AppButton(
                        label: AppStrings.skipForNow,
                        onTap: state.isLoading ? null : _onSkip,
                        variant: AppButtonVariant.ghost,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preference card ──────────────────────────────────────────────────────────

class _PreferenceCard extends StatelessWidget {
  final FinancialGoalModel goal;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Selected: gradient border (radial blue→orange per Figma)
    // Unselected: standard border
    if (selected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const RadialGradient(
              center: Alignment(-1.0, -0.5),
              radius: 2.0,
              colors: [Color(0xFF004AB0), Color(0xFFF36700)],
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: _CardContent(goal: goal, selected: true),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _CardContent(goal: goal, selected: false),
    );
  }
}

class _CardContent extends StatelessWidget {
  final FinancialGoalModel goal;
  final bool selected;

  const _CardContent({required this.goal, required this.selected});

  @override
  Widget build(BuildContext context) {
    final visual = _goalVisuals[goal.key] ?? _fallbackVisual;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: selected ? context.primaryLight : AppColors.transparent,
        borderRadius: BorderRadius.circular(selected ? 14.5 : 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon container (28x28)
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Icon(visual.icon, size: 20, color: visual.colorFill),
          ),
          const SizedBox(width: AppSpacing.base),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  goal.name,
                  style: AppTypography.labelMedium.copyWith(
                    fontFamily: 'BricolageGrotesque',
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.description ?? '',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
