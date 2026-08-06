import 'package:flutter_test/flutter_test.dart';
import 'package:finclar_ai/features/clara/presentation/widgets/clara_markdown.dart';

void main() {
  test('parses the assistant budget guide', () {
    const s = "I can't create a step-by-step budget guide inside the app for you, but I can outline the steps you can take:\n\n1. **Track Income**: Start by logging all your monthly income sources in the app.\n2. **List Expenses**: Record all fixed and variable expenses to see where your money goes.\n\nIf you want me to check your income and expenses before you set limits, just let me know!";
    final blocks = parseClaraMarkdown(s);
    for (final b in blocks) {
      print('${b.type} marker=${b.marker} :: ${b.spans.map((x) => '${x.bold ? "B" : x.italic ? "I" : "-"}[${x.text}]').join()}');
    }
    expect(blocks.length, 4);
    expect(blocks[1].marker, '1.');
    expect(blocks[1].spans.first.bold, true);
    print('plainLength=${claraPlainLength(s)} raw=${s.length}');
  });

  test('paragraph split only, no stray markers', () {
    const s = "In July 2026, you spent ₦65,000, all of which went towards health-related expenses. \n\nTo better manage your spending, consider reviewing your health expenses.";
    final blocks = parseClaraMarkdown(s);
    expect(blocks.length, 2);
    expect(blocks.every((b) => b.marker == null), true);
  });

  test('leaves lone asterisks and underscores alone', () {
    final blocks = parseClaraMarkdown('2 * 3 = 6 and snake_case_name stays');
    expect(blocks.single.spans.single.text, '2 * 3 = 6 and snake_case_name stays');
  });
}
