import 'package:flutter/material.dart';
import 'package:private_diary/models/diary_entry.dart';
import 'package:provider/provider.dart';
import 'package:private_diary/provider/diary_provider.dart';

class WriteEntryScreen extends StatefulWidget {
  final DiaryEntry? existingEntry;

  const WriteEntryScreen({super.key, this.existingEntry});

  @override
  State<WriteEntryScreen> createState() => _WriteEntryScreenState();
}

class _WriteEntryScreenState extends State<WriteEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late DateTime _entryDate;
  String _selectedMood = 'neutral';

  final List<Map<String, String>> _moods = const [
    {'label': 'happy', 'icon': '😊'},
    {'label': 'neutral', 'icon': '😐'},
    {'label': 'sad', 'icon': '😢'},
    {'label': 'angry', 'icon': '😠'},
    {'label': 'excited', 'icon': '🤩'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _bodyController = TextEditingController(text: widget.existingEntry?.body ?? '');
    _selectedMood = widget.existingEntry?.mood ?? 'neutral';
    _entryDate = widget.existingEntry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<DiaryProvider>();

    if (widget.existingEntry != null) {
      // Edit mode
      final entry = widget.existingEntry!;
      entry.title = title;
      entry.body = body;
      entry.mood = _selectedMood;
      provider.updateEntry(entry);
    } else {
      // Create mode
      provider.addEntry(
        DiaryEntry(
          title: title,
          body: body,
          date: DateTime.now(),
          mood: _selectedMood,
        ),
      );
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour12:$minute $period';
    return isToday ? 'Today • $time' : '${months[date.month - 1]} ${date.day}, ${date.year} • $time';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing ? 'Edit Entry' : 'New Entry',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Subtle brand touch consistent with the lock/PIN screens —
          // existing theme colors only, kept faint so it never competes
          // with reading or writing.
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(_entryDate),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'How are you feeling?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMoodPicker(context),

                  const SizedBox(height: 18),

                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts...',
                        border: InputBorder.none,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
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

  Widget _buildMoodPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _moods.map((mood) {
              final isSelected = mood['label'] == _selectedMood;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['label']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceVariant.withOpacity(0.35),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      mood['icon']!,
                      style: TextStyle(fontSize: isSelected ? 24 : 20),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            'Feeling $_selectedMood',
            key: ValueKey(_selectedMood),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}