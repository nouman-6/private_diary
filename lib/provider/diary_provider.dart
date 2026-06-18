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
}
