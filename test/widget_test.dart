import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/app.dart';

void main() {
  testWidgets('ONYX app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const OnyxApp());
    expect(find.text('ONYX'), findsOneWidget);
  });
}
