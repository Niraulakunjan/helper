import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_helper/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseHelperApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
