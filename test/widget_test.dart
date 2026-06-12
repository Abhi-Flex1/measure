import 'package:flutter_test/flutter_test.dart';
import 'package:ar_measure/main.dart';

void main() {
  testWidgets('AR Measure app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ARMeasureApp());
    expect(find.text('AR Camera Preview'), findsOneWidget);
  });
}
