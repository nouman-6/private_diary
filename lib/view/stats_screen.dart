import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:private_diary/provider/diary_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const Map<String, String> moodEmojis = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😢',
    'angry': '😠',
    'excited': '🤩',
  };

  static const Map<String, Color> moodColors = {
    'happy': Colors.amber,
    'neutral': Colors.grey,
    'sad': Colors.blue,
    'angry': Colors.red,
    'excited': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final moodCounts = provider.getMoodCounts();
    final streak = provider.getCurrentStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakCard(streak),
            const SizedBox(height: 24),
            const Text('Mood Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (moodCounts.isEmpty)
              const Text('No entries yet')
            else
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: moodCounts.entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: '${moodEmojis[e.key] ?? ''} ${e.value}',
                        color: moodColors[e.key] ?? Colors.grey,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak day${streak == 1 ? '' : 's'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Current streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}