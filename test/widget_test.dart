import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magang/main.dart';

void main() {
  testWidgets('Service App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ServiceApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
