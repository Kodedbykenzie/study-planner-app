import 'package:flutter/material.dart';
import '../models/task.dart';

class NewTaskScreen extends StatefulWidget {
  final ValueChanged<Task> onSave;
  const NewTaskScreen({super.key, required this.onSave});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _notifyDayBefore = false;
  bool _notifyHourBefore = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    DateTime? reminder;
    if (_selectedTime != null) {
      reminder = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
    final task = Task(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate,
      reminderTime: reminder,
      notifyDayBefore: _notifyDayBefore,
      notifyHourBefore: _notifyHourBefore,
    );
    widget.onSave(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Date: ${_formatDate(_selectedDate)}'),
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Time: ${_selectedTime != null ? _formatTime(_selectedTime!) : '--:--'}',
                  ),
                  IconButton(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Notify me 1 day before'),
                value: _notifyDayBefore,
                onChanged: (v) => setState(() => _notifyDayBefore = v),
              ),
              SwitchListTile(
                title: const Text('Notify me 1 hour before'),
                value: _notifyHourBefore,
                onChanged: (v) => setState(() => _notifyHourBefore = v),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }
}
