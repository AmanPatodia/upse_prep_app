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
import '../shared/widgets/app_shell.dart';

GoRouter createAppRouter({required bool isLoggedIn}) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute =
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
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/pyq/test/:testId',
        builder:
            (context, state) =>
                PyqTestScreen(testId: state.pathParameters['testId']!),
      ),
      GoRoute(
        path: '/pyq/result',
        builder: (context, state) => const PyqResultScreen(),
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
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/news',
                builder: (context, state) => const NewsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prelims',
                builder: (context, state) => const PrelimsOverviewScreen(),
              ),
              GoRoute(
                path: '/practice/mcq',
                builder:
                    (context, state) => McqPracticeScreen(
                      initialSubject: state.uri.queryParameters['subject'],
                      initialChapter: state.uri.queryParameters['chapter'],
                    ),
              ),
              GoRoute(
                path: '/practice/mock',
                builder: (context, state) => const MockTestScreen(),
              ),
              GoRoute(
                path: '/pyq',
                builder: (context, state) => const PyqScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mains',
                builder: (context, state) => const MainsOverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/current-affairs',
                builder: (context, state) => const CurrentAffairsScreen(),
              ),
              GoRoute(
                path: '/ai',
                builder: (context, state) => const AiUpdatesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
