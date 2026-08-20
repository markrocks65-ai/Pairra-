/// Centralized route paths + names. Screens reference these constants rather
/// than hard-coded strings so the map stays refactor-safe as the app grows.
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signUp = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const verifyPhone = '/verify-phone';
  static const consent = '/consent';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const profile = '/profile';
  static const discover = '/discover';
  static const matches = '/matches';
  static const messages = '/messages';
  static const dates = '/dates';
  static const safety = '/safety';
  static const premium = '/premium';
  static const aiAssistant = '/ai-assistant';
  static const notifications = '/notifications';
  static const settings = '/settings';

  /// Routes reachable while signed out. Used by the redirect guard.
  static const unauthenticated = {
    welcome,
    login,
    signUp,
    forgotPassword,
  };
}
