import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safewalk/app.dart';

void main() {
  testWidgets('safe walk app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
