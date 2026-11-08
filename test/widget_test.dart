import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takluk/main.dart';

void main() {
  testWidgets('TaklukApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaklukApp()));
    expect(find.byType(TaklukApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
