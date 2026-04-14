import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  String? get errorMessage => _errorMessage;

  // Keep your API key secure
  final String _apiKey = '';

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''
You are an expert student scheduling assistant. The user has provided these tasks in JSON: $tasksJson.

Analyze overlaps and suggest a balanced schedule considering urgency (1-5), importance (1-5), and energy level.

Please provide EXACTLY these 4 headers in your response, followed by the content:
### Detected Conflicts
### Ranked Tasks
### Recommended Schedule
### Explanation
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      if (responseText.isEmpty) {
        _errorMessage = "AI returned no data.";
      } else {
        _currentAnalysis = _parseResponse(responseText);
      }
    } catch (e) {
      _errorMessage = 'Failed to analyze: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    // Initialize with "No data" so the screen isn't blank if parsing fails
    String conflicts = "No conflicts detected.";
    String rankedTasks = "No ranking available.";
    String recommendedSchedule = "No schedule generated.";
    String explanation = "No explanation provided.";

    // FIX 2: Split by the markdown header
    final sections = fullText.split('###');

    for (var section in sections) {
      // FIX 3: Trim the section! This removes leading newlines/spaces
      // so that .startsWith() actually works.
      final trimmedSection = section.trim();

      if (trimmedSection.startsWith('Detected Conflicts')) {
        conflicts = trimmedSection.replaceFirst('Detected Conflicts', '').trim();
      } else if (trimmedSection.startsWith('Ranked Tasks')) {
        rankedTasks = trimmedSection.replaceFirst('Ranked Tasks', '').trim();
      } else if (trimmedSection.startsWith('Recommended Schedule')) {
        recommendedSchedule = trimmedSection.replaceFirst('Recommended Schedule', '').trim();
      } else if (trimmedSection.startsWith('Explanation')) {
        explanation = trimmedSection.replaceFirst('Explanation', '').trim();
      }
    }

    return ScheduleAnalysis(
      conflict: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}