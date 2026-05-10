import 'package:flutter_test/flutter_test.dart';

import 'package:cat_oracle/app/app.dart';

void main() {
  testWidgets('shows the Cat Oracle home page', (WidgetTester tester) async {
    await tester.pumpWidget(const CatOracleApp());

    expect(find.text('Cat Oracle'), findsOneWidget);
    expect(find.text('Hand scannen'), findsOneWidget);
    expect(find.text('Demo-Lesung'), findsOneWidget);
  });
}
