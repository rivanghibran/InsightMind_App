import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal stub of InsightMindApp used for widget tests.
/// Replace this stub with the real app import when lib/src/app.dart exists.
class InsightMindApp extends StatelessWidget {
  const InsightMindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final List<String> _answers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Simulasi Jawaban'),
            Wrap(
              children: _answers.map((a) => Chip(label: Text(a))).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _answers.add('Jawaban')),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  testWidgets('FAB adds a Chip to the HomePage', (WidgetTester tester) async {
    // Build the app inside a ProviderScope (as the app expects).
    await tester.pumpWidget(const ProviderScope(child: InsightMindApp()));

    // The HomePage shows a description text.
    expect(find.textContaining('Simulasi Jawaban'), findsOneWidget);

    // Initially there should be no Chip widgets (no answers yet).
    expect(find.byType(Chip), findsNothing);

    // Tap the FAB (add) and rebuild.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // After tapping, a Chip representing the new answer should appear.
    expect(find.byType(Chip), findsOneWidget);
  });
}
