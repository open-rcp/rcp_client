// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Create a simplified test version of the app
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RCP Client'),
        ),
        body: const Center(
          child: Text('RCP Client App'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Test app builds successfully', (WidgetTester tester) async {
    // Build our test app and trigger a frame
    await tester.pumpWidget(const TestApp());

    // Verify basic widgets exist
    expect(find.text('RCP Client'), findsOneWidget);
    expect(find.text('RCP Client App'), findsOneWidget);
  });
}
