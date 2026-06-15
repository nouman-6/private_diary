import 'package:flutter/material.dart';
import 'package:private_diary/models/diary_entry.dart';
import 'package:provider/provider.dart';
import 'package:private_diary/provider/diary_provider.dart';

class WriteEntryScreen extends StatefulWidget {
  final DiaryEntry? existingEntry; // null = new entry, non-null = edit mode

  const WriteEntryScreen({super.key, this.existingEntry});

  @override
  State<WriteEntryScreen> createState() => _WriteEntryScreenState();
}

class _WriteEntryScreenState extends State<WriteEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String _selectedMood = 'neutral';

  final List<Map<String, dynamic>> _moods = [
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMoodPicker(),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodPicker() {
    return Row(
      children: _moods.map((mood) {
        final isSelected = mood['label'] == _selectedMood;
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['label']),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(mood['icon'], style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }
}