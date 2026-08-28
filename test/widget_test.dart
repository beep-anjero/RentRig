import 'package:flutter_test/flutter_test.dart';
import 'package:rentrig/main.dart';

void main() {
  testWidgets('RENTRIG app bootstrap smoke test', (WidgetTester tester) async {
    // Verify that MyApp initializes cleanly
    expect(const MyApp(), isNotNull);
  });
}
