import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

// Hand-rolled rather than using a markdown package because the typewriter
// reveal needs to truncate *rendered* output, not the raw source — a package
// fed truncated markdown shows a literal "**Track Inco" until the closing
// fence arrives, then reflows. If Clara ever emits tables, links or fenced
// code blocks, swap this for `gpt_markdown` and drop the reveal to a fade.
enum ClaraBlockType { paragraph, heading, bullet, numbered }

class ClaraInlineSpan {
  final String text;
  final bool bold;
  final bool italic;
  final bool code;

  const ClaraInlineSpan(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
  });

  ClaraInlineSpan copyWithText(String value) => ClaraInlineSpan(
        value,
        bold: bold,
        italic: italic,
        code: code,
      );
}

class ClaraBlock {
  final ClaraBlockType type;
  final String? marker;
  final List<ClaraInlineSpan> spans;

  const ClaraBlock({required this.type, this.marker, required this.spans});

  int get plainLength =>
      spans.fold(0, (sum, s) => sum + s.text.characters.length);
}

final _inlinePattern = RegExp(
  r'\*\*(.+?)\*\*|__(.+?)__|(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])|(?<![\w_])_(?!\s)(.+?)(?<!\s)_(?![\w_])|`([^`]+)`',
  dotAll: true,
);

List<ClaraInlineSpan> _parseInline(String line) {
  final spans = <ClaraInlineSpan>[];
  var cursor = 0;
  for (final m in _inlinePattern.allMatches(line)) {
    if (m.start > cursor) {
      spans.add(ClaraInlineSpan(line.substring(cursor, m.start)));
    }
    if (m.group(1) != null || m.group(2) != null) {
      spans.add(ClaraInlineSpan(m.group(1) ?? m.group(2)!, bold: true));
    } else if (m.group(3) != null || m.group(4) != null) {
      spans.add(ClaraInlineSpan(m.group(3) ?? m.group(4)!, italic: true));
    } else if (m.group(5) != null) {
      spans.add(ClaraInlineSpan(m.group(5)!, code: true));
    }
    cursor = m.end;
  }
  if (cursor < line.length) {
    spans.add(ClaraInlineSpan(line.substring(cursor)));
  }
  return spans.isEmpty ? [ClaraInlineSpan(line)] : spans;
}

final _headingPattern = RegExp(r'^#{1,6}\s+(.*)$');
final _bulletPattern = RegExp(r'^\s*[-*•]\s+(.*)$');
final _numberedPattern = RegExp(r'^\s*(\d+)[.)]\s+(.*)$');

/// Parses Clara's backend markdown into renderable blocks. Supports headings,
/// bullet and numbered lists, bold, italic and inline code — everything the
/// assistant actually emits. Unknown syntax falls through as plain text.
List<ClaraBlock> parseClaraMarkdown(String source) {
  final blocks = <ClaraBlock>[];
  final buffer = <String>[];

  void flushParagraph() {
    if (buffer.isEmpty) return;
    final text = buffer.join('\n').trim();
    buffer.clear();
    if (text.isEmpty) return;
    blocks.add(ClaraBlock(
      type: ClaraBlockType.paragraph,
      spans: _parseInline(text),
    ));
  }

  for (final rawLine in source.replaceAll('\r\n', '\n').split('\n')) {
    final line = rawLine.trimRight();
    if (line.trim().isEmpty) {
      flushParagraph();
      continue;
    }

    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      blocks.add(ClaraBlock(
        type: ClaraBlockType.heading,
        spans: _parseInline(heading.group(1)!.trim()),
      ));
      continue;
    }

    final numbered = _numberedPattern.firstMatch(line);
    if (numbered != null) {
      flushParagraph();
      blocks.add(ClaraBlock(
        type: ClaraBlockType.numbered,
        marker: '${numbered.group(1)}.',
        spans: _parseInline(numbered.group(2)!.trim()),
      ));
      continue;
    }

    final bullet = _bulletPattern.firstMatch(line);
    if (bullet != null) {
      flushParagraph();
      blocks.add(ClaraBlock(
        type: ClaraBlockType.bullet,
        marker: '•',
        spans: _parseInline(bullet.group(1)!.trim()),
      ));
      continue;
    }

    buffer.add(line);
  }
  flushParagraph();
  return blocks;
}

/// The rendered (markdown-free) length of [source] — what the typewriter
/// actually reveals, so timing matches what the user sees rather than the raw
/// syntax length.
int claraPlainLength(String source) =>
    parseClaraMarkdown(source).fold(0, (sum, b) => sum + b.plainLength);

/// Renders parsed markdown. When [visibleGlyphs] is non-null only that many
/// rendered characters are shown, which is how the typewriter reveal works;
/// a caret is appended at the cut point while [showCaret] is true.
class ClaraMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final int? visibleGlyphs;
  final bool showCaret;
  final Widget? caret;

  const ClaraMarkdownText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.visibleGlyphs,
    this.showCaret = false,
    this.caret,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = parseClaraMarkdown(text);
    if (blocks.isEmpty) return const SizedBox.shrink();

    var remaining = visibleGlyphs ?? -1;
    final children = <Widget>[];

    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (remaining == 0) break;

      List<ClaraInlineSpan> spans = block.spans;
      var isLastVisible = i == blocks.length - 1;
      if (remaining > 0) {
        if (block.plainLength > remaining) {
          spans = _truncate(spans, remaining);
          remaining = 0;
          isLastVisible = true;
        } else {
          remaining -= block.plainLength;
          if (remaining == 0) isLastVisible = true;
        }
      }

      if (children.isNotEmpty) {
        children.add(SizedBox(height: _gapBefore(block)));
      }
      children.add(_buildBlock(
        context,
        block,
        spans,
        withCaret: showCaret && isLastVisible,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  double _gapBefore(ClaraBlock block) {
    switch (block.type) {
      case ClaraBlockType.bullet:
      case ClaraBlockType.numbered:
        return AppSpacing.xs;
      case ClaraBlockType.heading:
        return AppSpacing.md;
      case ClaraBlockType.paragraph:
        return AppSpacing.sm;
    }
  }

  List<ClaraInlineSpan> _truncate(List<ClaraInlineSpan> spans, int budget) {
    final result = <ClaraInlineSpan>[];
    var left = budget;
    for (final span in spans) {
      final length = span.text.characters.length;
      if (length <= left) {
        result.add(span);
        left -= length;
        if (left == 0) break;
      } else {
        result.add(span.copyWithText(span.text.characters.take(left).toString()));
        break;
      }
    }
    return result;
  }

  Widget _buildBlock(
    BuildContext context,
    ClaraBlock block,
    List<ClaraInlineSpan> spans, {
    required bool withCaret,
  }) {
    final content = _richText(context, block, spans, withCaret: withCaret);
    if (block.marker == null) return content;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              block.marker!,
              style: baseStyle.copyWith(
                color: context.textQuaternary,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _richText(
    BuildContext context,
    ClaraBlock block,
    List<ClaraInlineSpan> spans, {
    required bool withCaret,
  }) {
    final blockStyle = block.type == ClaraBlockType.heading
        ? baseStyle.copyWith(
            fontSize: baseStyle.fontSize! + 1,
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 600)],
          )
        : baseStyle;

    return Text.rich(
      TextSpan(
        children: [
          for (final span in spans) _span(context, span, blockStyle),
          if (withCaret && caret != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: caret!,
            ),
        ],
      ),
    );
  }

  InlineSpan _span(
    BuildContext context,
    ClaraInlineSpan span,
    TextStyle blockStyle,
  ) {
    var style = blockStyle;
    if (span.bold) {
      style = style.copyWith(
        color: context.textPrimary,
        fontVariations: const [FontVariation('wght', 700)],
      );
    }
    if (span.italic) style = style.copyWith(fontStyle: FontStyle.italic);
    if (span.code) {
      style = style.copyWith(
        color: AppColors.primary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
      return TextSpan(text: span.text, style: style);
    }
    return TextSpan(text: span.text, style: style);
  }
}
