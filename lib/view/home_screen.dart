import 'package:flutter/material.dart';
import 'package:private_diary/models/diary_entry.dart';
import 'package:private_diary/view/write_entry_screen.dart';
import 'package:provider/provider.dart';
import 'package:private_diary/provider/diary_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final entries = diaryProvider.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('My Diary')),
      body: entries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, index) => _buildEntryCard(entries[index], context),
            ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteEntryScreen()),
    );
  },
  child: const Icon(Icons.add),
),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your diary is empty.\nTap + to write your first entry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry, BuildContext context) {
    return Dismissible(
      key: Key(entry.key.toString()),
    direction: DismissDirection.endToStart, // swipe left to delete
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    confirmDismiss: (direction) => _confirmDelete(context),
    onDismissed: (direction) {
      context.read<DiaryProvider>().deleteEntry(entry);
    },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(entry.title),
          subtitle: Text(
            entry.body.length > 60 ? '${entry.body.substring(0, 60)}...' : entry.body,
          ),
          trailing: Text(_formatDate(entry.date)),
          onTap: () {
        Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WriteEntryScreen(existingEntry: entry)),
        );
      },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false; // if dialog dismissed without choice, return false
}
}