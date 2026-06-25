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

  // Maps each mood to a role from the app's existing ColorScheme, so the
  // chart stays inside the current theme instead of introducing a separate
  // ad-hoc palette (amber/grey/blue/red/purple).
  Color _moodColor(BuildContext context, String mood) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (mood) {
      case 'happy':
        return colorScheme.primary;
      case 'excited':
        return colorScheme.tertiary;
      case 'sad':
        return colorScheme.secondary;
      case 'angry':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final moodCounts = provider.getMoodCounts();
    final streak = provider.getCurrentStreak();
    final totalEntries = moodCounts.values.fold<int>(0, (a, b) => a + b);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // Same faint brand touch used across the other screens.
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.local_fire_department_rounded,
                          iconBg: colorScheme.tertiaryContainer,
                          iconColor: colorScheme.onTertiaryContainer,
                          value: '$streak',
                          label: 'Day${streak == 1 ? '' : 's'} streak',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.menu_book_rounded,
                          iconBg: colorScheme.primaryContainer,
                          iconColor: colorScheme.onPrimaryContainer,
                          value: '$totalEntries',
                          label: 'Total entries',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mood Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  if (moodCounts.isEmpty)
                    _buildEmptyMoods(context)
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sections: moodCounts.entries.map((e) {
                                        return PieChartSectionData(
                                          value: e.value.toDouble(),
                                          title: '',
                                          color: _moodColor(context, e.key),
                                          radius: 38,
                                        );
                                      }).toList(),
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 60,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$totalEntries',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        totalEntries == 1 ? 'entry' : 'entries',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 16,
                              runSpacing: 10,
                              children: moodCounts.entries.map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _moodColor(context, e.key),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${moodEmojis[e.key] ?? ''} ${_capitalize(e.key)} (${e.value})',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMoods(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 40, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No entries yet',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}