import 'package:go_router/go_router.dart';

import '../pages/welcome_page.dart';
import '../pages/login_page.dart';
import '../pages/otp_page.dart';
import '../pages/splash_screen.dart';
import '../../home/pages/home_page.dart';
import 'auth_route_names.dart';

final List<RouteBase> authRoutes = [
  GoRoute(
    path: AuthRouteNames.welcome,
    builder: (context, state) => const WelcomePage(),
  ),
  GoRoute(
    path: AuthRouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: AuthRouteNames.otp,
    builder: (context, state) => const OtpPage(),
  ),
  GoRoute(
    path: AuthRouteNames.home,
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: AuthRouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
];
