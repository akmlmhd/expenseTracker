import 'package:expenses_tracker/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:expenses_tracker/src/features/auth/presentation/providers/auth_bloc.dart';
import 'package:expenses_tracker/src/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/src/routing/global_navigator.dart';
import 'package:expenses_tracker/src/routing/app_routes.dart';
import 'package:expenses_tracker/src/config/app_config.dart';
import 'package:expenses_tracker/src/services/storage_service.dart';

import 'package:expenses_tracker/src/features/auth/presentation/screens/login_screen.dart';
import 'package:expenses_tracker/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:expenses_tracker/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:expenses_tracker/src/features/onboarding/presentation/screens/onboarding_page.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: _initialLocation(),
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          repository: context.read<AuthRepository>(),
        ),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          repository: context.read<AuthRepository>(),
        ),
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          repository: context.read<AuthRepository>(),
        ),
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const MainNavigationScreen(currentIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.transactions,
      name: 'transactions',
      builder: (context, state) => const MainNavigationScreen(currentIndex: 1),
    ),
    GoRoute(
      path: AppRoutes.addExpense,
      name: 'addExpense',
      builder: (context, state) => const MainNavigationScreen(currentIndex: 2),
    ),
    GoRoute(
      path: AppRoutes.budget,
      name: 'budget',
      builder: (context, state) => const MainNavigationScreen(currentIndex: 3),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const MainNavigationScreen(currentIndex: 4),
    ),
  ],
);

String _initialLocation() {
  final completedOnboarding =
      StorageService.instance.getBool('onboarding_completed') ?? false;
  if (!completedOnboarding) return AppRoutes.onboarding;
  if (!AppConfig.authEnabled) return AppRoutes.home;

  final hasCachedSession =
      StorageService.instance.getBool('firebase_session_active') ?? false;
  return hasCachedSession ? AppRoutes.home : AppRoutes.login;
}
