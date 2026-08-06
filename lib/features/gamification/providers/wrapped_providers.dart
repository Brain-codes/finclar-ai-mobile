import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../data/models/wrapped_model.dart';
import '../data/repositories/wrapped_repository.dart';

final wrappedRepositoryProvider = Provider<WrappedRepository>((ref) {
  return WrappedRepository(ref.watch(apiClientProvider));
});

/// The period a wrapped recap covers. Null fields fall back to the current
/// year/month on the backend. A record so the family key compares by value.
typedef WrappedPeriod = ({int? year, int? month});

/// Monthly recap. Pass a period, or `(year: null, month: null)` for the
/// current one.
final wrappedProvider = FutureProvider.family<WrappedModel, WrappedPeriod>((
  ref,
  period,
) {
  return ref
      .watch(wrappedRepositoryProvider)
      .getWrapped(year: period.year, month: period.month);
});
