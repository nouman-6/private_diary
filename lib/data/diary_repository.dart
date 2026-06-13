import 'package:hive_ce/hive.dart';
import 'package:private_diary/models/diary_entry.dart';

class DiaryRepository {
  final Box<DiaryEntry> _box = Hive.box<DiaryEntry>('diary_entries');

  List<DiaryEntry> getAllEntries() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addEntry(DiaryEntry entry) async {
    await _box.add(entry);
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await entry.save();
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    await entry.delete();
  }
}