import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/ai/presentation/ai_updates_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/current_affairs/presentation/current_affairs_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/mains/presentation/mains_overview_screen.dart';
import '../features/mcq/presentation/mcq_practice_screen.dart';
import '../features/mcq/presentation/mock_test_screen.dart';
import '../features/news/presentation/news_screen.dart';
import '../features/prelims/presentation/prelims_overview_screen.dart';
import '../features/pyq/presentation/pyq_result_screen.dart';
import '../features/pyq/presentation/pyq_screen.dart';
import '../features/pyq/presentation/pyq_test_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../shared/widgets/app_shell.dart';

GoRouter createAppRouter({required AuthCubit authCubit}) {
  final refreshNotifier = _AuthRouterRefreshNotifier(authCubit.stream);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isLoggedIn = authCubit.state.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder:
            (context, state) =>
                _buildTransitionPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder:
            (context, state) =>
                _buildTransitionPage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder:
            (context, state) =>
                _buildTransitionPage(state: state, child: const SignupScreen()),
      ),
      GoRoute(
        path: '/pyq/test/:testId',
        pageBuilder:
            (context, state) => _buildTransitionPage(
              state: state,
              child: PyqTestScreen(testId: state.pathParameters['testId']!),
            ),
      ),
      GoRoute(
        path: '/pyq/result',
        pageBuilder:
            (context, state) =>
                _buildTransitionPage(state: state, child: const PyqResultScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const DashboardScreen(),
                    ),
              ),
              GoRoute(
                path: '/news',
                pageBuilder:
                    (context, state) =>
                        _buildTransitionPage(state: state, child: const NewsScreen()),
              ),
              GoRoute(
                path: '/settings',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const SettingsScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prelims',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const PrelimsOverviewScreen(),
                    ),
              ),
              GoRoute(
                path: '/practice/mcq',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: McqPracticeScreen(
                        initialSubject: state.uri.queryParameters['subject'],
                        initialChapter: state.uri.queryParameters['chapter'],
                      ),
                    ),
              ),
              GoRoute(
                path: '/practice/mock',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const MockTestScreen(),
                    ),
              ),
              GoRoute(
                path: '/pyq',
                pageBuilder:
                    (context, state) =>
                        _buildTransitionPage(state: state, child: const PyqScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mains',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const MainsOverviewScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/current-affairs',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const CurrentAffairsScreen(),
                    ),
              ),
              GoRoute(
                path: '/ai',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const AiUpdatesScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                pageBuilder:
                    (context, state) => _buildTransitionPage(
                      state: state,
                      child: const AnalyticsScreen(),
                    ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthRouterRefreshNotifier extends ChangeNotifier {
  _AuthRouterRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _buildTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
