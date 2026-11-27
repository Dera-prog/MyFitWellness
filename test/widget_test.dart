import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitwellness/widgets/brand.dart';

void main() {
  testWidgets('brand wordmark renders both halves', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandWordmark(fontSize: 18))),
      ),
    );

    expect(find.textContaining('MYFIT', findRichText: true), findsOneWidget);
    expect(find.textContaining('WELLNESS', findRichText: true), findsOneWidget);
  });
}
