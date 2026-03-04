import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<String> generateFinancialReport(Map<String, dynamic> snapshot) async {
    final prompt = '''
      You are an expert financial advisor. Analyze the following anonymized financial snapshot and provide a structured report.
      
      Snapshot: ${jsonEncode(snapshot)}
      
      Provide the report in the following JSON format:
      {
        "healthScore": 0-100,
        "strengths": ["string"],
        "warnings": ["string"],
        "advice": ["string"],
        "strategies": ["string"]
      }
      
      Ensure the advice is practical and relevant to an African context (e.g., mention MMFs, SACCOs if applicable).
      Keep it professional yet encouraging.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '{}';
    } catch (e) {
      print('Gemini error: $e');
      return '{}';
    }
  }

  Future<String> getDailyTip() async {
    const prompt = 'Provide a short, one-sentence financial tip for the day. Keep it actionable and smart.';
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Save today, thrive tomorrow.';
    } catch (e) {
      return 'Track your expenses daily to stay in control.';
    }
  }
}
