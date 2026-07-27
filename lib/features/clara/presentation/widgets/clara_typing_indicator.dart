import 'package:flutter/material.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ClaraTypingIndicator extends StatefulWidget {
  const ClaraTypingIndicator({super.key});

  @override
  State<ClaraTypingIndicator> createState() => _ClaraTypingIndicatorState();
}

class _ClaraTypingIndicatorState extends State<ClaraTypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: -5)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
            child: AnimatedBuilder(
              animation: _animations[i],
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, _animations[i].value),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: ctx.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
