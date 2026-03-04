import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthwise/services/gemini_service.dart';

// Assuming API key is provided later or hardcoded for now (In a real app, use env vars)
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService(apiKey: 'YOUR_GEMINI_API_KEY'));

final dailyTipProvider = FutureProvider<String>((ref) async {
  return ref.watch(geminiServiceProvider).getDailyTip();
});

final aiInsightProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, snapshot) async {
  return ref.watch(geminiServiceProvider).generateFinancialReport(snapshot);
});
