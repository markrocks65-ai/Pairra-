import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pairra/app/pairra_app.dart';
import 'package:pairra/features/auth/application/auth_providers.dart';
import 'package:pairra/features/auth/data/mock_auth_repository.dart';

void main() {
  setUpAll(() {
    // Don't hit the network for fonts in tests; use the bundled fallback.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('boots through splash to Welcome when signed out',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            MockAuthRepository(
                latency: Duration.zero, initialDelay: Duration.zero),
          ),
        ],
        child: const PairraApp(),
      ),
    );

    // First frame: splash (lifecycle unknown).
    await tester.pump();
    // Resolve the initial auth stream event → redirect to Welcome.
    await tester.pump(const Duration(milliseconds: 50));
    // Let the route transition + entrance animations complete.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));

    // The two clear paths prove we've landed on Welcome.
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Dating without the guesswork.'), findsWidgets);
  });
}
