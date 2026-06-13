import 'package:hive_ce/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String mood; // e.g. 'happy', 'sad', 'neutral'

  DiaryEntry({
    required this.title,
    required this.body,
    required this.date,
    required this.mood,
  });
}