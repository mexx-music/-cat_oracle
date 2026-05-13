import 'package:flutter_test/flutter_test.dart';

import 'package:cat_oracle/app/app.dart';

void main() {
  testWidgets('shows the Cat Oracle home page', (WidgetTester tester) async {
    await tester.pumpWidget(const CatOracleApp());

    expect(find.text('Handlesen'), findsOneWidget);
    expect(find.text('Astrologie'), findsOneWidget);
    expect(find.text('Tarot'), findsOneWidget);
    expect(find.text('Grafologie'), findsOneWidget);
  });
}
