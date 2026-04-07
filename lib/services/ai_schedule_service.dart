import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier{

  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

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
    
    You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format: $tasksJson.
    
    Your job is to analyze these tasks. identify any overlaps or conflicts in their start and end time and suggest a better balance schedule.
    consider their urgency, importance, and required energy level.
    
    Please provide exactly 4 sections of markdown text:
    
    1. ### Detected Conflicts
    List any Scheduling conflicts or overlaps in the tasks.
    
    2. ### Ranked Tasks
    Rank the tasks based on their urgency and importance with the reasoning behind each of the recommended schedule.
    
    3. ### Recommended Schedule
    Recommended schedule based on the analysis.
    
    
    
    ''';


  }catch (e) {
    finally

  }
  }
}