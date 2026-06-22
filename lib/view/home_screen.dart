import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:private_diary/models/diary_entry.dart';
import 'package:private_diary/provider/theme_provider.dart';
import 'package:private_diary/view/settings_screen.dart';
import 'package:private_diary/view/stats_screen.dart';
import 'package:private_diary/view/write_entry_screen.dart';
import 'package:provider/provider.dart';
import 'package:private_diary/provider/diary_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final entries = diaryProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<DiaryProvider>().search(value);
                },
              )
            : const Text('My Diary'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
                context.read<DiaryProvider>().clearSearch();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? _buildEmptyState(_isSearching)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: _buildEntryCard(context, entries[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => const WriteEntryScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1), // slides up from bottom
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: child,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'No entries found for your search.'
                : 'Your diary is empty.\nTap + to write your first entry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget _buildEntryCard(DiaryEntry entry, BuildContext context) {
  //   return Dismissible(
  //     key: Key(entry.key.toString()),
  //     direction: DismissDirection.endToStart, // swipe left to delete
  //     background: Container(
  //       alignment: Alignment.centerRight,
  //       padding: const EdgeInsets.only(right: 20),
  //       margin: const EdgeInsets.only(bottom: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.red,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: const Icon(Icons.delete, color: Colors.white),
  //     ),
  //     confirmDismiss: (direction) => _confirmDelete(context),
  //     onDismissed: (direction) {
  //       final provider = context.read<DiaryProvider>();
  //       final deletedEntry = entry;

  //       provider.deleteEntry(entry);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Entry deleted'),
  //           duration: const Duration(seconds: 3),
  //           action: SnackBarAction(
  //             label: 'Undo',
  //             onPressed: () {
  //               provider.addEntry(
  //                 DiaryEntry(
  //                   title: deletedEntry.title,
  //                   body: deletedEntry.body,
  //                   date: deletedEntry.date,
  //                   mood: deletedEntry.mood,
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //     child: Card(
  //       margin: const EdgeInsets.only(bottom: 10),
  //       child: ListTile(
  //         title: Text(entry.title),
  //         subtitle: Text(
  //           entry.body.length > 60
  //               ? '${entry.body.substring(0, 60)}...'
  //               : entry.body,
  //         ),
  //         trailing: Text(_formatDate(entry.date)),
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (_) => WriteEntryScreen(existingEntry: entry),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEntryCard(BuildContext context, DiaryEntry entry) {
    return Dismissible(
      key: Key(entry.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) {
        final provider = context.read<DiaryProvider>();
        final deletedEntry = entry;

        provider.deleteEntry(entry);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entry deleted'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.addEntry(
                  DiaryEntry(
                    title: deletedEntry.title,
                    body: deletedEntry.body,
                    date: deletedEntry.date,
                    mood: deletedEntry.mood,
                  ),
                );
              },
            ),
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WriteEntryScreen(existingEntry: entry),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title.isEmpty ? 'Untitled' : entry.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(entry.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.body.length > 80
                      ? '${entry.body.substring(0, 80)}...'
                      : entry.body,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _moodEmoji(entry.mood),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _moodEmoji(String mood) {
    const map = {
      'happy': '😊',
      'neutral': '😐',
      'sad': '😢',
      'angry': '😠',
      'excited': '🤩',
    };
    return map[mood] ?? '😐';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text(
              'Are you sure you want to delete this entry? This cannot be undone.',
            ),
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
