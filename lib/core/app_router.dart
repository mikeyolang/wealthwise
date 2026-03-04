import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/main_shell.dart';
import 'package:wealthwise/features/auth/screens/splash_screen.dart';
import 'package:wealthwise/features/auth/screens/login_screen.dart';
import 'package:wealthwise/features/auth/screens/register_screen.dart';
import 'package:wealthwise/features/auth/screens/onboarding_screen.dart';
import 'package:wealthwise/features/dashboard/screens/dashboard_screen.dart';
import 'package:wealthwise/features/transactions/screens/add_transaction_screen.dart';
import 'package:wealthwise/features/transactions/screens/transaction_list_screen.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:wealthwise/features/goals/screens/goals_dashboard_screen.dart';
import 'package:wealthwise/features/goals/screens/add_goal_screen.dart';
import 'package:wealthwise/features/goals/screens/goal_detail_screen.dart';
import 'package:wealthwise/features/goals/goal_model.dart';
import 'package:wealthwise/features/analytics/screens/analytics_screen.dart';
import 'package:wealthwise/features/profile/screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionListScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsDashboardScreen(),
          routes: [
            GoRoute(
               path: 'detail',
               builder: (context, state) => GoalDetailScreen(goal: state.extra as GoalModel),
            ),
          ],
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] == 'income' 
            ? TransactionType.income 
            : TransactionType.expense;
        return AddTransactionScreen(type: type);
      },
    ),
    GoRoute(
      path: '/add-goal',
      builder: (context, state) => const AddGoalScreen(),
    ),
  ],
);
