/// @title Markdown view tests
/// @notice The AI answer renderer keeps bold and lists without a package.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/widgets/ai/markdown/markdown_view.dart';

void main() {
  testWidgets('bold and a list render from markdown', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownView(
            data: '**tebal**\n\n- satu\n- dua',
            color: Color(0xFF111111),
          ),
        ),
      ),
    );

    expect(find.text('satu'), findsOneWidget);
    expect(find.text('dua'), findsOneWidget);
    expect(find.text('•  '), findsNWidgets(2));
    expect(
      find.byWidgetPredicate((Widget widget) {
        if (widget is! RichText) {
          return false;
        }
        var found = false;
        widget.text.visitChildren((InlineSpan span) {
          if (span is TextSpan &&
              span.text == 'tebal' &&
              span.style?.fontWeight == FontWeight.w700) {
            found = true;
          }
          return true;
        });
        return found;
      }),
      findsOneWidget,
    );
  });
}
