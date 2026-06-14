import 'package:flutter/material.dart';
import 'package:private_diary/data/diary_repository.dart';
import 'package:private_diary/models/diary_entry.dart';

class DiaryProvider extends ChangeNotifier {
  final _repo = DiaryRepository();

  List<DiaryEntry> entries = [];

  DiaryProvider() {
    _loadEntries();
  }

  void _loadEntries() {
    entries = _repo.getAllEntries();
    notifyListeners();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    await _repo.addEntry(entry);
    _loadEntries();
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    await _repo.deleteEntry(entry);
    _loadEntries();
  }
}