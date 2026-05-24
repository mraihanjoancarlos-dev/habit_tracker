// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HabitProvider extends ChangeNotifier {
  List<dynamic> _habits   = [];
  Map<String, dynamic>? _todayData;
  Map<String, dynamic>? _stats;
  bool _loading  = false;
  String? _error;

  List<dynamic> get habits         => _habits;
  Map<String, dynamic>? get today  => _todayData;
  Map<String, dynamic>? get stats  => _stats;
  bool get isLoading               => _loading;
  String? get error                => _error;

  int get completedToday =>
      (_todayData?['habits'] as List? ?? []).where((h) => h['is_completed'] == 1 || h['is_completed'] == true).length;

  int get totalToday => (_todayData?['habits'] as List? ?? []).length;

  double get completionRate => totalToday > 0 ? completedToday / totalToday : 0;

  Future<void> loadToday() async {
    _loading = true;
    _error   = null;
    notifyListeners();

    final res = await ApiService.getTodayHabits();
    _loading  = false;

    if (res['success'] == true) {
      _todayData = res['data'];
      _habits    = _todayData?['habits'] ?? [];
    } else {
      _error = res['message'];
    }
    notifyListeners();
  }

  Future<void> loadStats() async {
    final res = await ApiService.getStats();
    if (res['success'] == true) {
      _stats = res['data'];
      notifyListeners();
    }
  }

  Future<bool> toggle(int habitId, {String? note}) async {
    final res = await ApiService.toggleHabit(habitId, note: note);
    if (res['success'] == true) {
      // Update local state
      final habits = _todayData?['habits'] as List? ?? [];
      for (var h in habits) {
        if (h['id'] == habitId) {
          h['is_completed'] = res['data']['is_completed'] ? 1 : 0;
          h['streak']       = res['data']['streak'];
          break;
        }
      }
      // Recalculate completion
      final done = habits.where((h) => h['is_completed'] == 1).length;
      _todayData?['completed']       = done;
      _todayData?['completion_rate'] = habits.isNotEmpty ? (done / habits.length * 100).round() : 0;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createHabit(Map<String, dynamic> data) async {
    final res = await ApiService.createHabit(data);
    if (res['success'] == true) {
      await loadToday();
      return true;
    }
    _error = res['message'];
    notifyListeners();
    return false;
  }

  Future<bool> updateHabit(Map<String, dynamic> data) async {
    final res = await ApiService.updateHabit(data);
    if (res['success'] == true) {
      await loadToday();
      return true;
    }
    return false;
  }

  Future<bool> deleteHabit(int id) async {
    final res = await ApiService.deleteHabit(id);
    if (res['success'] == true) {
      _habits.removeWhere((h) => h['id'] == id);
      (_todayData?['habits'] as List?)?.removeWhere((h) => h['id'] == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}
