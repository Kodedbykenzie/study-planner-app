import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskBottomSheet extends StatefulWidget {
  final Task? task;
  final ValueChanged<Task> onSave;
  final VoidCallback? onDelete;

  const TaskBottomSheet({
    super.key,
    this.task,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  DateTime? _reminderTime;
  bool _isDone = false;
  bool _notifyDayBefore = false;
  bool _notifyHourBefore = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _reminderTime = widget.task?.reminderTime;
    _isDone = widget.task?.isDone ?? false;
    _notifyDayBefore = widget.task?.notifyDayBefore ?? false;
    _notifyHourBefore = widget.task?.notifyHourBefore ?? false;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;
    final Task saved = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate,
      reminderTime: _reminderTime,
      isDone: _isDone,
      notifyDayBefore: _notifyDayBefore,
      notifyHourBefore: _notifyHourBefore,
    );
    widget.onSave(saved);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Due: ${_formatDate(_selectedDate)}'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _reminderTime != null
                        ? 'Reminder: ${_formatTime(_reminderTime!)}'
                        : 'Set Reminder',
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _reminderTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                  if (_reminderTime != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear',
                      onPressed: () => setState(() => _reminderTime = null),
                    ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDone,
                onChanged: (val) => setState(() => _isDone = val ?? false),
                title: const Text('Completed'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifyDayBefore,
                onChanged: (val) => setState(() => _notifyDayBefore = val),
                title: const Text('Notify me 1 day before'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifyHourBefore,
                onChanged: (val) => setState(() => _notifyHourBefore = val),
                title: const Text('Notify me 1 hour before'),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.task != null && widget.onDelete != null)
                    TextButton.icon(
                      onPressed: widget.onDelete,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleSave,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
