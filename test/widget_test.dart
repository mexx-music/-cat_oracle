import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cat_oracle/app/app.dart';

void main() {
  testWidgets('shows the Cat Oracle home page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CatOracleApp());
    await tester.pumpAndSettle();

    expect(find.text('Palm Reading'), findsOneWidget);
    expect(find.text('Astrology'), findsOneWidget);
    expect(find.text('Tarot'), findsOneWidget);
    expect(find.text('Graphology'), findsOneWidget);
  });
}
