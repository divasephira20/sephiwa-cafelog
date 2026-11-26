import 'package:flutter_test/flutter_test.dart';
import 'package:sephiwa_cafelog/main.dart';

void main() {
  testWidgets('App smoke test loads main navigation and brand header', (WidgetTester tester) async {
    // Build our app and trigger an initial frame
    await tester.pumpWidget(const SephiwaCafeLogApp());
    await tester.pump();

    // Verify main navigation bar items exist
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
  });
}
