import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/challenge_model.dart';
import '../../domain/challenge_availability.dart';
import '../../providers/challenge_providers.dart';
import 'challenge_amount_sheet.dart';
import 'challenge_modal.dart';
import 'challenge_utils.dart';
import 'record_challenge_entry_sheet.dart';
import 'start_challenge_sheet.dart';

/// Surfaces at most one challenge prompt per app open, in priority order:
/// Friday owns its day, the weekend nudge only matters Friday to Sunday, and
/// the category one fills the quiet stretches. Stacking two modals on someone
/// opening the app would be worse than showing neither.
Future<void> maybeShowChallengePrompts(
  BuildContext context,
  ProviderContainer container,
) async {
  final challenges = await _loadChallenges(container);
  if (challenges == null || !context.mounted) return;

  if (await maybeShowFridayChallengePrompt(
    context,
    container,
    challenges: challenges,
  )) {
    return;
  }
  if (!context.mounted) return;

  if (await maybeShowWeekendChallengePrompt(
    context,
    container,
    challenges: challenges,
  )) {
    return;
  }
  if (!context.mounted) return;

  await maybeShowCategoryChallengePrompt(
    context,
    container,
    challenges: challenges,
  );
}

/// Shows the Friday Savings challenge modal. Returns whether it appeared.
///
/// It runs **every** Friday, whether or not last Friday was saved — that's the
/// point of the streak. The once-per-week guard only stops it reappearing on
/// every app open within the same Friday.
///
/// The real trigger is the backend's weekly reminder push; [fromPush] skips the
/// local day guard because the backend already decided it's time. Without it
/// this falls back to a client-side day check, so the challenge still surfaces
/// if push is denied or undelivered.
Future<bool> maybeShowFridayChallengePrompt(
  BuildContext context,
  ProviderContainer container, {
  bool fromPush = false,
  String? challengeId,
  List<ChallengeModel>? challenges,
}) async {
  final week = isoWeekLabel(DateTime.now());

  if (!fromPush) {
    if (DateTime.now().weekday != DateTime.friday) return false;
    if (await StorageService.getChallengePromptWeek() == week) return false;
  }

  final list = challenges ?? await _loadChallenges(container);
  if (list == null) return false;

  // Type-scoped: with three types running, the first active challenge is no
  // longer necessarily the savings one, and an entry must not land on a
  // spend-based challenge.
  final active = list
      .where(
        (c) =>
            c.isActive &&
            c.type == ChallengeType.fridaySavings &&
            (challengeId == null || c.id == challengeId),
      )
      .firstOrNull;

  // Marked before showing so a dismissed prompt does not return on next open.
  await StorageService.setChallengePromptWeek(week);
  if (!context.mounted) return false;

  await showChallengeModal(
    context,
    ChallengeType.fridaySavings,
    // Save the usual amount straight away.
    onStart: () =>
        _saveFriday(context, container, active, active?.weeklyTarget),
    // Or set a different amount for this particular Friday.
    onEnterAmount: () async {
      final amount = await showChallengeAmountSheet(
        context,
        initialAmount: active?.weeklyTarget,
      );
      if (amount == null || !context.mounted) return false;
      return _saveFriday(context, container, active, amount);
    },
  );
  return true;
}

/// The no-spend challenge only exists between Friday and Sunday, so the nudge
/// goes out once as the weekend opens and the challenge it creates expires
/// with it.
Future<bool> maybeShowWeekendChallengePrompt(
  BuildContext context,
  ProviderContainer container, {
  bool fromPush = false,
  List<ChallengeModel>? challenges,
}) async {
  final now = DateTime.now();
  final week = isoWeekLabel(now);

  if (!fromPush) {
    if (!isWeekendOpen(now)) return false;
    if (await StorageService.getWeekendPromptWeek() == week) return false;
  }

  final list = challenges ?? await _loadChallenges(container);
  if (list == null) return false;
  if (list.any((c) => c.isActive && c.type == ChallengeType.noSpend)) {
    return false;
  }

  await StorageService.setWeekendPromptWeek(week);
  if (!context.mounted) return false;

  return _promptToStart(
    context,
    ChallengeType.noSpend,
    endDate: weekendEnd(now),
  );
}

/// Unlike the other two this has no natural day to land on, so it picks a
/// random one every time — see [nextCategoryPromptDate].
Future<bool> maybeShowCategoryChallengePrompt(
  BuildContext context,
  ProviderContainer container, {
  bool fromPush = false,
  List<ChallengeModel>? challenges,
}) async {
  final now = DateTime.now();

  if (!fromPush) {
    final stored = await StorageService.getCategoryPromptDate();
    // A fresh install only schedules — nobody should be nudged into a budget
    // challenge on the day they signed up.
    if (stored == null) {
      await StorageService.setCategoryPromptDate(
        dateKey(nextCategoryPromptDate(now)),
      );
      return false;
    }
    final due = DateTime.tryParse(stored);
    if (due == null || now.isBefore(due)) return false;
  }

  final list = challenges ?? await _loadChallenges(container);
  if (list == null) return false;

  // Rescheduled even when the prompt is skipped, so it doesn't fire the moment
  // an existing category challenge ends.
  await StorageService.setCategoryPromptDate(
    dateKey(nextCategoryPromptDate(now)),
  );

  if (list.any((c) => c.isActive && c.type == ChallengeType.budgetCategory)) {
    return false;
  }
  if (!context.mounted) return false;

  return _promptToStart(context, ChallengeType.budgetCategory);
}

/// Shows the type's intro modal and, if the user goes through with it, opens
/// the create form and lands them on the challenge they just started.
Future<bool> _promptToStart(
  BuildContext context,
  ChallengeType type, {
  DateTime? endDate,
}) async {
  ChallengeModel? created;
  await showChallengeModal(
    context,
    type,
    onStart: () async {
      created = await showStartChallengeSheet(
        context,
        type: type,
        endDate: endDate,
      );
      return created != null;
    },
  );

  final challenge = created;
  if (challenge != null && context.mounted) {
    context.push(RouteNames.challengeDetail, extra: challenge);
  }
  return true;
}

/// Opens the receipt-backed entry sheet, creating the challenge first if this
/// is the user's very first Friday. Returns whether the entry was recorded —
/// anything short of that leaves the modal up to try again.
Future<bool> _saveFriday(
  BuildContext context,
  ProviderContainer container,
  ChallengeModel? active,
  double? amount,
) async {
  var target = amount;

  // "Start saving" with no challenge yet has no usual amount to fall back on,
  // so ask before anything is created.
  if (target == null) {
    target = await showChallengeAmountSheet(context);
    if (target == null || !context.mounted) return false;
  }

  var challenge = active;

  if (challenge == null) {
    // No challenge yet — the first save is what starts it, and this amount
    // becomes the weekly target suggested from then on.
    try {
      challenge = await container
          .read(challengesProvider.notifier)
          .create(weeklyTarget: target);
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
      return false;
    }
  }

  if (!context.mounted) return false;

  final recorded = await showRecordChallengeEntrySheet(
    context,
    challengeId: challenge.id,
    weeklyTarget: target,
    title: 'Attach your proof',
  );
  return recorded == true;
}

Future<List<ChallengeModel>?> _loadChallenges(
  ProviderContainer container,
) async {
  try {
    return await container.read(challengesProvider.future);
  } catch (e) {
    Log.e('Challenge prompt skipped', error: e);
    return null;
  }
}
