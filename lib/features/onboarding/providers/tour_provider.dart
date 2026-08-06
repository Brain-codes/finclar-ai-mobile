import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';

/// The targets in the home tour, in the order they're shown. All six are on
/// screen at the same time (home body + the shell's nav bar), so the tour runs
/// start-to-finish in one sitting and never navigates mid-flow.
enum TourStep { balance, add, expenses, budget, groups, clara }

/// Owns the GlobalKeys the shell attaches to each target, plus whether a tour
/// is currently *queued*.
///
/// **Queued, not "unseen".** An earlier version showed the tour to anyone
/// whose flag wasn't set, which meant every existing user got ambushed by it
/// mid-session on the release that introduced the flag. The tour now only ever
/// runs when something explicitly asks for it — registration, or the Settings
/// replay row.
class TourNotifier extends Notifier<bool> {
  final Map<TourStep, GlobalKey> keys = {
    for (final step in TourStep.values) step: GlobalKey(),
  };

  /// True when a tour is waiting to run. Starts false so nothing can fire
  /// before storage answers.
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    state = await StorageService.isTourPending();
  }

  List<GlobalKey> get orderedKeys =>
      TourStep.values.map((s) => keys[s]!).toList();

  /// Queues the tour for the next time home is shown. Called on registration
  /// and from "Replay app tour".
  Future<void> enqueue() async {
    await StorageService.setTourPending();
    state = true;
    Log.d('[Tour] Queued');
  }

  /// Consumes the queued tour. Called immediately *before* showing it, so a
  /// dismissal can never bring it back.
  Future<void> consume() async {
    if (!state) return;
    state = false;
    await StorageService.clearTourPending();
    Log.d('[Tour] Consumed');
  }
}

final tourProvider = NotifierProvider<TourNotifier, bool>(TourNotifier.new);
