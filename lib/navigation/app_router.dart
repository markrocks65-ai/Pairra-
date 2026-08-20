import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/consent_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/phone_verification_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/application/onboarding_providers.dart';
import '../features/onboarding/domain/onboarding_profile.dart';
import '../features/dates/presentation/dates_home_screen.dart';
import '../features/discovery/presentation/discover_screen.dart';
import '../features/discovery/presentation/matches_screen.dart';
import '../features/messaging/presentation/conversation_list_screen.dart';
import '../features/notifications/presentation/notification_center_screen.dart';
import '../features/onboarding/presentation/onboarding_flow_screen.dart';
import '../features/profile/presentation/my_profile_screen.dart';
import '../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../features/safety/presentation/safety_home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shell/presentation/main_shell_screen.dart';
import '../features/subscription/presentation/premium_screen.dart';
import 'app_routes.dart';

/// The app router. Its `redirect` is the single gate that enforces the auth
/// lifecycle:
///   unknown            → Splash
///   signed out         → Welcome / Login / Sign up / Forgot password
///   signed in, no consent → Consent (blocks everything else)
///   signed in, email unverified → Email verification (blocks everything else)
///   fully authenticated → Home (and kept out of the auth funnel)
///
/// The guard re-runs whenever [authControllerProvider] changes, via a
/// [Listenable] bridged from Riverpod.
/// One navigator per tab branch. Giving each branch its own navigator key lets
/// drill-in screens (a candidate's profile, a match's detail, a venue…) stack
/// *within* the branch, so the floating nav bar stays visible and each tab
/// keeps its own back stack when you switch away and return.
final _discoverNavKey = GlobalKey<NavigatorState>(debugLabel: 'discover');
final _matchesNavKey = GlobalKey<NavigatorState>(debugLabel: 'matches');
final _datesNavKey = GlobalKey<NavigatorState>(debugLabel: 'dates');
final _messagesNavKey = GlobalKey<NavigatorState>(debugLabel: 'messages');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      // Still resolving the persisted session → hold on splash.
      if (auth.lifecycle == AuthLifecycle.unknown) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!auth.isAuthenticated) {
        return AppRoutes.unauthenticated.contains(loc)
            ? null
            : AppRoutes.welcome;
      }

      // Signed in: enforce legal consent, then email verification.
      if (auth.needsConsent) {
        return loc == AppRoutes.consent ? null : AppRoutes.consent;
      }
      if (auth.needsEmailVerification) {
        return loc == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
      }

      // First-time users are guided into onboarding. Once they've started it,
      // skipped it, or completed it, they're free to move around (they can
      // resume from Home). Onboarding is otherwise skippable, never a trap.
      final onboardingStatus =
          ref.read(onboardingControllerProvider).draft.status;
      if (onboardingStatus == OnboardingStatus.notStarted) {
        return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      // Fully authenticated: don't let them sit in the auth/splash funnel.
      const funnel = {
        AppRoutes.splash,
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
        AppRoutes.consent,
        AppRoutes.verifyEmail,
      };
      if (funnel.contains(loc)) return AppRoutes.discover;
      return null; // the tab shell + onboarding + pushed screens are allowed
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.consent,
        builder: (_, _) => const ConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, _) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyPhone,
        builder: (_, _) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingFlowScreen(),
      ),
      // The primary tab shell — one persistent Liquid Glass nav across the
      // five branches.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(navigatorKey: _discoverNavKey, routes: [
            GoRoute(
                path: AppRoutes.discover,
                builder: (_, _) => const DiscoverScreen()),
          ]),
          StatefulShellBranch(navigatorKey: _matchesNavKey, routes: [
            GoRoute(
                path: AppRoutes.matches,
                builder: (_, _) => const MatchesScreen()),
          ]),
          StatefulShellBranch(navigatorKey: _datesNavKey, routes: [
            GoRoute(
                path: AppRoutes.dates,
                builder: (_, _) => const DatesHomeScreen()),
          ]),
          StatefulShellBranch(navigatorKey: _messagesNavKey, routes: [
            GoRoute(
                path: AppRoutes.messages,
                builder: (_, _) => const ConversationListScreen()),
          ]),
          StatefulShellBranch(navigatorKey: _profileNavKey, routes: [
            GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const MyProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.safety,
        builder: (_, _) => const SafetyHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (_, _) => const PremiumScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (_, _) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's auth + onboarding state to a [Listenable] so GoRouter
/// re-evaluates its redirect whenever either changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _authSub = ref.listen<AuthState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
    _onboardingSub = ref.listen<OnboardingState>(
      onboardingControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _authSub;
  late final ProviderSubscription<OnboardingState> _onboardingSub;

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    super.dispose();
  }
}
