import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Track Smarter',
      description: 'Clean and simple expense tracking for your daily life.',
      icon: Icons.track_changes_rounded,
    ),
    OnboardingData(
      title: 'Goal Oriented',
      description: 'Set goals and let our AI help you reach them faster.',
      icon: Icons.ads_click_rounded,
    ),
    OnboardingData(
      title: 'AI Insights',
      description: 'Get personalized financial advice powered by Gemini.',
      icon: Icons.psychology_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _onboardingData.length + 1, // +1 for Quiz
              itemBuilder: (context, index) {
                if (index < _onboardingData.length) {
                  return _buildOnboardingPage(_onboardingData[index]);
                } else {
                  return const FinancialPersonalityQuiz();
                }
              },
            ),
          ),
          _buildNavigation(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.accentEmerald.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: AppTheme.accentEmerald),
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 60),
          Text(
            data.title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              _onboardingData.length + 1,
              (index) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppTheme.accentEmerald : AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_currentPage < _onboardingData.length) {
                _pageController.nextPage(duration: 300.ms, curve: Curves.easeIn);
              }
            },
            backgroundColor: AppTheme.accentEmerald,
            child: Icon(
              _currentPage == _onboardingData.length ? Icons.check : Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialPersonalityQuiz extends StatefulWidget {
  const FinancialPersonalityQuiz({super.key});

  @override
  State<FinancialPersonalityQuiz> createState() => _FinancialPersonalityQuizState();
}

class _FinancialPersonalityQuizState extends State<FinancialPersonalityQuiz> {
  int _currentQuestionIndex = 0;
  final List<Question> _questions = [
    Question(
      text: 'How do you usually handle a surplus of money at the end of the month?',
      options: ['Save it all', 'Treat myself', 'Invest it', 'Not sure, it disappears'],
    ),
    Question(
      text: 'What is your primary financial goal?',
      options: ['Living debt-free', 'Building wealth', 'Buying a house', 'Retiring early'],
    ),
    Question(
      text: 'How often do you check your bank balance?',
      options: ['Every day', 'Once a week', 'Once a month', 'Only when card declines'],
    ),
  ];

  void _answerQuestion(int index) async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      // Mark onboarding as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      
      // Finish quiz and go to login
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalize Your Experience',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.accentGold),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          Text(
            question.text,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ...List.generate(
            question.options.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(question.options[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({required this.title, required this.description, required this.icon});
}

class Question {
  final String text;
  final List<String> options;

  Question({required this.text, required this.options});
}
