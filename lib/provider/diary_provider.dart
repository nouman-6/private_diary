import 'package:flutter/material.dart';
import 'package:private_diary/data/diary_repository.dart';
import 'package:private_diary/models/diary_entry.dart';

class DiaryProvider extends ChangeNotifier {
  final _repo = DiaryRepository();
  String _searchQuery = '';

  DiaryProvider() {
    _loadEntries();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    await _repo.addEntry(entry);
    _loadEntries();
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    await _repo.deleteEntry(entry);
    _loadEntries();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _repo.updateEntry(entry);
    _loadEntries();
  }

  List<DiaryEntry> get entries {
    if (_searchQuery.isEmpty) return _allEntries;
    return _repo.searchEntries(_searchQuery);
  }

  List<DiaryEntry> _allEntries = [];

  void _loadEntries() {
    _allEntries = _repo.getAllEntries();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Map<String, int> getMoodCounts() {
    final counts = <String, int>{};
    for (final entry in _allEntries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return counts;
  }

  int getCurrentStreak() {
    if (_allEntries.isEmpty) return 0;

    final dates =
        _allEntries
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (final date in dates) {
      if (date == checkDate ||
          date == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = date;
      } else {
        break;
      }
    }
    return streak;
  }
}
