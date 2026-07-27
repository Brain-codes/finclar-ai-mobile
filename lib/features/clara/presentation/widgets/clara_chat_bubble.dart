import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/clara_message_model.dart';

// User messages: white rounded pill, right-aligned.
class ClaraUserBubble extends StatelessWidget {
  final String text;
  const ClaraUserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 14,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ),
    );
  }
}

// Clara replies: plain text, left-aligned, no bubble background.
// When [animate] is true (a freshly received reply), the text reveals with a
// typewriter effect and fires a single haptic tick as it begins.
class ClaraAssistantBubble extends StatefulWidget {
  final String text;
  final bool animate;
  const ClaraAssistantBubble({
    super.key,
    required this.text,
    this.animate = false,
  });

  @override
  State<ClaraAssistantBubble> createState() => _ClaraAssistantBubbleState();
}

class _ClaraAssistantBubbleState extends State<ClaraAssistantBubble>
    with TickerProviderStateMixin {
  AnimationController? _reveal;
  AnimationController? _blink;
  int _glyphCount = 0;

  @override
  void initState() {
    super.initState();
    // Only the freshly-received reply animates; history bubbles render plainly
    // and spin up no controllers.
    if (!widget.animate) return;

    _glyphCount = widget.text.characters.length;
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..repeat(reverse: true);
    _reveal = AnimationController(
      vsync: this,
      duration: claraRevealDuration(widget.text),
    );
    // Haptic the moment the bubble switches into its typewriter reveal.
    HapticFeedback.lightImpact();
    _reveal!.forward().whenComplete(() {
      if (mounted) _blink?.stop();
    });
  }

  @override
  void dispose() {
    _reveal?.dispose();
    _blink?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: _reveal == null
            ? _text(context, widget.text, showCaret: false)
            : AnimatedBuilder(
                animation: _reveal!,
                builder: (context, _) {
                  final shown = (_glyphCount * _reveal!.value).round();
                  final revealed =
                      widget.text.characters.take(shown).toString();
                  final typing = _reveal!.value < 1.0;
                  return _text(context, revealed, showCaret: typing);
                },
              ),
      ),
    );
  }

  Widget _text(BuildContext context, String value, {required bool showCaret}) {
    final style = AppTypography.bodySmall.copyWith(
      color: context.textSecondary,
      fontSize: 14,
      height: 1.5,
      fontVariations: const [FontVariation('wght', 500)],
    );
    if (!showCaret) return Text(value, style: style);

    return Text.rich(
      TextSpan(
        text: value,
        style: style,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AnimatedBuilder(
              animation: _blink!,
              builder: (context, _) => Opacity(
                opacity: _blink!.value,
                child: Container(
                  width: 2,
                  height: 15,
                  margin: const EdgeInsets.only(left: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
