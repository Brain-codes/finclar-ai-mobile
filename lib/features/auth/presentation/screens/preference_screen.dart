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
import '../../providers/preference_provider.dart';

// ─── Preference data model ────────────────────────────────────────────────────

class _Preference {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color colorFill;

  const _Preference({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorFill,
  });
}

const _preferences = [
  _Preference(
    id: 'save',
    title: AppStrings.prefSaveTitle,
    description: AppStrings.prefSaveDesc,
    icon: AppIcons.wallet,
    colorFill: AppColors.categoryTransport,
  ),
  _Preference(
    id: 'track',
    title: AppStrings.prefTrackTitle,
    description: AppStrings.prefTrackDesc,
    icon: AppIcons.chart,
    colorFill: AppColors.categoryShopping,
  ),
  _Preference(
    id: 'budget',
    title: AppStrings.prefBudgetTitle,
    description: AppStrings.prefBudgetDesc,
    icon: AppIcons.budget,
    colorFill: AppColors.primary,
  ),
  _Preference(
    id: 'control',
    title: AppStrings.prefControlTitle,
    description: AppStrings.prefControlDesc,
    icon: AppIcons.briefcase,
    colorFill: AppColors.success,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PreferenceScreen extends ConsumerStatefulWidget {
  const PreferenceScreen({super.key});

  @override
  ConsumerState<PreferenceScreen> createState() => _PreferenceScreenState();
}

// Maps the local preference ID to the backend goal string.
const _goalIds = {
  'save': 'save_more',
  'track': 'track_expenses',
  'budget': 'budget_better',
  'control': 'financial_control',
};

class _PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  String? _selectedId;

  Future<void> _onContinue() async {
    if (_selectedId == null) return;
    final goal = _goalIds[_selectedId!]!;
    await ref.read(preferenceProvider.notifier).saveGoals([goal]);
  }

  Future<void> _onSkip() async {
    await ref.read(preferenceProvider.notifier).skipGoals();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceProvider);

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
                        ...List.generate(_preferences.length, (i) {
                          final pref = _preferences[i];
                          final selected = _selectedId == pref.id;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i < _preferences.length - 1
                                  ? AppSpacing.sm
                                  : 0,
                            ),
                            child: _PreferenceCard(
                              preference: pref,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedId = pref.id),
                            ),
                          );
                        }),

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
  final _Preference preference;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceCard({
    required this.preference,
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
          child: _CardContent(preference: preference, selected: true),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _CardContent(preference: preference, selected: false),
    );
  }
}

class _CardContent extends StatelessWidget {
  final _Preference preference;
  final bool selected;

  const _CardContent({required this.preference, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
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
            child: Icon(preference.icon, size: 20, color: preference.colorFill),
          ),
          const SizedBox(width: AppSpacing.base),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  preference.title,
                  style: AppTypography.labelMedium.copyWith(
                    fontFamily: 'BricolageGrotesque',
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preference.description,
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
