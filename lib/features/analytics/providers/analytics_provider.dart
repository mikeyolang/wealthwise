import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService(apiKey: ''));

final dailyTipProvider = FutureProvider<String>((ref) async {
  return ref.watch(geminiServiceProvider).getDailyTip();
});

final aiInsightProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, snapshot) async {
  return ref.watch(geminiServiceProvider).generateFinancialReport(snapshot);
});
