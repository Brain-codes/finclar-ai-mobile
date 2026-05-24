import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

// 6-box OTP / passcode input.
// Single hidden TextField captures real input; 6 styled boxes render it.
// Usage:
//   AppOtpField(onCompleted: (code) { ... })
//   AppOtpField(obscureText: true, hasError: true, errorText: '...')
class AppOtpField extends StatefulWidget {
  final int length;
  final bool obscureText;
  final bool hasError;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;

  const AppOtpField({
    super.key,
    this.length = 6,
    this.obscureText = false,
    this.hasError = false,
    this.autofocus = false,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.controller,
  });

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _hasFocus = _focusNode.hasFocus);
      });
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Hidden TextField that captures all input
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _onChanged,
                  decoration: const InputDecoration(counterText: ''),
                  style: const TextStyle(fontSize: 1, color: Colors.transparent),
                ),
              ),
              // Visual boxes
              IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(widget.length, (i) {
                    final filled = i < _controller.text.length;
                    final isActive = _hasFocus && i == _controller.text.length;
                    final char = filled ? _controller.text[i] : '';

                    Color borderColor;
                    double borderWidth;
                    if (widget.hasError) {
                      borderColor = AppColors.error;
                      borderWidth = 1.5;
                    } else if (isActive) {
                      borderColor = AppColors.primary;
                      borderWidth = 1.5;
                    } else {
                      borderColor = context.inputBorder;
                      borderWidth = 1;
                    }

                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: filled
                          ? Text(
                              widget.obscureText ? '●' : char,
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textTertiary,
                                fontSize: widget.obscureText ? 12 : 16,
                                height: 1.5,
                              ),
                            )
                          : (isActive
                              ? _Cursor()
                              : const SizedBox.shrink()),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Error / info text
          if (widget.hasError && widget.errorText != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                widget.errorText!,
                style: AppTypography.errorText.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Blinking cursor shown in the active empty box
class _Cursor extends StatefulWidget {
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 20,
        color: AppColors.primary,
      ),
    );
  }
}
