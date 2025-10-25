import 'package:flutter_test/flutter_test.dart';
import 'package:product_verification/main.dart';

void main() {
  testWidgets('MBS Verify app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MBSApp());
    expect(find.text('MBS Verify'), findsOneWidget);
  });
}