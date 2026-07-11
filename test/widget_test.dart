import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/app.dart';

void main() {
  testWidgets('La aplicación se carga correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('SafeWalk'), findsOneWidget);
  });
}
