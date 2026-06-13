import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/income_source_model.dart';
import '../../providers/income_setup_provider.dart';

Future<IncomeSourceModel?> showAddSourceSheet(BuildContext context) {
  return showAppSheet<IncomeSourceModel>(
    context,
    title: 'Add a source',
    avoidKeyboard: true,
    children: [const _AddSourceContent()],
  );
}

class _AddSourceContent extends ConsumerStatefulWidget {
  const _AddSourceContent();

  @override
  ConsumerState<_AddSourceContent> createState() => _AddSourceContentState();
}

class _AddSourceContentState extends ConsumerState<_AddSourceContent> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _hasText = _controller.text.trim().isNotEmpty),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    setState(() => _isLoading = true);
    try {
      final source =
          await ref.read(incomeSourcesProvider.notifier).addSource(name);
      if (mounted) Navigator.of(context).pop(source);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Source',
          controller: _controller,
          hint: 'e.g. Side hustle, Pension…',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Done',
          onTap: _hasText && !_isLoading ? _submit : null,
          isLoading: _isLoading,
          height: 48,
        ),
      ],
    );
  }
}
