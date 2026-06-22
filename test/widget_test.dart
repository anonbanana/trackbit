import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackbit/app.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TrackBitApp()),
    );
    expect(find.byType(TrackBitApp), findsOneWidget);
  });
}
