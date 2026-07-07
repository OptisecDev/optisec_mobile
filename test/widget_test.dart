import 'package:flutter_test/flutter_test.dart';

import 'package:optisec_mobile/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const OptiSecApp());
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(Duration.zero);
  });
}
