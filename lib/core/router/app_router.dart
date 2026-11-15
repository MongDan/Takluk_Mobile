import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/archive/presentation/screens/archive_screen.dart';
import '../../features/bookmark/presentation/screens/bookmark_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/player/presentation/screens/player_screen.dart';
import '../../features/payment/presentation/screens/checkout_screen.dart';
import '../../features/payment/presentation/screens/qris_screen.dart';
import '../../features/payment/presentation/screens/payment_success_screen.dart';
import '../../features/archive/presentation/screens/quiz_screen.dart';
import '../../features/profile/presentation/screens/device_management_screen.dart';
import '../../features/profile/presentation/screens/transaction_history_screen.dart';
import '../../features/profile/presentation/screens/referral_screen.dart';
import '../widgets/animated_branch_container.dart';
import '../widgets/shell_scaffold.dart';

// Motion tokens for route transitions. Kept in one place so every screen
// changes with the same smooth, consistent feel.
const Duration _pageEnterDuration = Duration(milliseconds: 420);
const Duration _pageExitDuration = Duration(milliseconds: 300);
const Curve _pageEnterCurve = Curves.easeOutCubic;
const Curve _pageExitCurve = Curves.easeInCubic;

/// Fade + gentle lift for top-level screens (splash, onboarding, auth, shell)
/// so switching screens never feels abrupt.
CustomTransitionPage<void> _fadeThroughPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _pageEnterDuration,
    reverseTransitionDuration: _pageExitDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: _pageEnterCurve,
        reverseCurve: _pageExitCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Slide from the right + fade for pushed detail screens.
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _pageEnterDuration,
    reverseTransitionDuration: _pageExitDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: _pageEnterCurve,
        reverseCurve: _pageExitCurve,
      );
      final parallax = CurvedAnimation(
        parent: secondaryAnimation,
        curve: _pageEnterCurve,
        reverseCurve: _pageExitCurve,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.06, 0),
        ).animate(parallax),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.16, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const AuthScreen()),
      ),
      // Main Shell with Bottom Navigation
      StatefulShellRoute(
        pageBuilder: (context, state, navigationShell) => _fadeThroughPage(
          state,
          ShellScaffold(navigationShell: navigationShell),
        ),
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/archive',
                builder: (context, state) => const ArchiveScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmark',
                builder: (context, state) => const BookmarkScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Push screens
      GoRoute(
        path: '/player/:videoId',
        pageBuilder: (context, state) => _slidePage(
          state,
          PlayerScreen(videoId: state.pathParameters['videoId']!),
        ),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            _slidePage(state, const CheckoutScreen()),
      ),
      GoRoute(
        path: '/qris/:transactionId',
        pageBuilder: (context, state) => _slidePage(
          state,
          QrisScreen(transactionId: state.pathParameters['transactionId']!),
        ),
      ),
      GoRoute(
        path: '/payment-success',
        pageBuilder: (context, state) =>
            _fadeThroughPage(state, const PaymentSuccessScreen()),
      ),
      GoRoute(
        path: '/quiz/:courseId',
        pageBuilder: (context, state) => _slidePage(
          state,
          QuizScreen(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '/device-management',
        pageBuilder: (context, state) =>
            _slidePage(state, const DeviceManagementScreen()),
      ),
      GoRoute(
        path: '/transaction-history',
        pageBuilder: (context, state) =>
            _slidePage(state, const TransactionHistoryScreen()),
      ),
      GoRoute(
        path: '/referral',
        pageBuilder: (context, state) =>
            _slidePage(state, const ReferralScreen()),
      ),
    ],
  );
});
