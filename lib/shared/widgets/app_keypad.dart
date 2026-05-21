import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';

// ─── Controller ──────────────────────────────────────────────────────────────

class AppKeypadController extends ChangeNotifier {
  String _raw = '';

  String get raw => _raw;

  double? get value {
    if (_raw.isEmpty) return null;
    final s = _raw.endsWith('.') ? '${_raw}0' : _raw;
    return double.tryParse(s);
  }

  bool get hasValidAmount {
    final v = value;
    return v != null && v > 0;
  }

  String get displayAmount {
    if (_raw.isEmpty) return '₦0.00';
    final normalized = _raw.endsWith('.') ? '${_raw}00' : _raw;
    final v = double.tryParse(normalized);
    if (v == null) return '₦0.00';
    final parts = normalized.split('.');
    final intPart = _formatIntPart(parts[0]);
    final decPart = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    return '₦$intPart.$decPart';
  }

  void onKey(String key) {
    if (key == '⌫') {
      if (_raw.isNotEmpty) _raw = _raw.substring(0, _raw.length - 1);
    } else if (key == '.') {
      if (_raw.isNotEmpty && !_raw.contains('.')) _raw += '.';
    } else {
      if (_raw.contains('.')) {
        final decimals = _raw.split('.')[1];
        if (decimals.length >= 2) return;
      }
      _raw = _raw == '0' ? key : _raw + key;
    }
    notifyListeners();
  }

  void clear() {
    _raw = '';
    notifyListeners();
  }

  String _formatIntPart(String s) {
    if (s.isEmpty) return '0';
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class AppKeypad extends StatelessWidget {
  final AppKeypadController controller;

  const AppKeypad({super.key, required this.controller});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows
          .map(
            (row) => Row(
              children: row
                  .map((k) => _KeyCell(label: k, onTap: controller.onKey))
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

// ─── Key cell ─────────────────────────────────────────────────────────────────

class _KeyCell extends StatelessWidget {
  final String label;
  final void Function(String) onTap;
  const _KeyCell({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 76,
          child: Center(
            child: label == '⌫'
                ? Icon(AppIcons.back, size: 22, color: context.textQuaternary)
                : Text(label, style: AppTypography.keypad),
          ),
        ),
      ),
    );
  }
}
