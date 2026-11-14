import 'package:flutter_test/flutter_test.dart';
import 'package:datacore_mobile/main.dart';

void main() {
  testWidgets('DataCore Customer App smoke test', (WidgetTester tester) async {
    expect(const DataCoreCustomerApp(), isNotNull);
  });
}
