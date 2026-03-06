import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _timerFinished = true;
      });
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() async {
    if (!_timerFinished) return;

    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) async {
        if (user != null) {
          context.go('/dashboard');
        } else {
          final prefs = await SharedPreferences.getInstance();
          final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
          
          if (mounted) {
            if (onboardingComplete) {
              context.go('/login');
            } else {
              context.go('/onboarding');
            }
          }
        }
      },
      loading: () {},
      error: (_, __) => context.go('/login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen(authStateProvider, (previous, next) async {
      if (_timerFinished) {
        next.when(
          data: (user) async {
            if (user != null) {
              context.go('/dashboard');
            } else {
              final prefs = await SharedPreferences.getInstance();
              final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
              if (mounted) {
                if (onboardingComplete) {
                  context.go('/login');
                } else {
                  context.go('/onboarding');
                }
              }
            }
          },
          loading: () {},
          error: (_, __) => context.go('/login'),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentEmerald.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: AppTheme.accentEmerald,
              ),
            ).animate()
              .scale(duration: 600.ms, curve: Curves.easeOut)
              .fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Text(
              'Wealthwise',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.5, end: 0),
            const SizedBox(height: 8),
            Text(
              'Your AI-Powered Financial Guide',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ).animate()
              .fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
