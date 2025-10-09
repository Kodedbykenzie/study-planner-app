import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_bottom_sheet.dart';
import 'new_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<Task> allTasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    List<Task> tasks = await StorageService.loadTasks();
    setState(() => allTasks = tasks);
  }

  List<Task> getTasksForDay(DateTime day) {
    return allTasks
        .where(
          (task) =>
              task.dueDate.year == day.year &&
              task.dueDate.month == day.month &&
              task.dueDate.day == day.day,
        )
        .toList();
  }

  Future<void> deleteTask(Task task) async {
    final List<Task> tasks = await StorageService.loadTasks();
    tasks.removeWhere((t) => t.id == task.id);
    await StorageService.saveTasks(tasks);
    loadTasks();
  }

  void toggleTaskDone(Task task, bool value) async {
    final List<Task> tasks = await StorageService.loadTasks();
    final int index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isDone: value);
      await StorageService.saveTasks(tasks);
      loadTasks();
    }
  }

  void editTask(Task oldTask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskBottomSheet(
        task: oldTask,
        onSave: (updatedTask) async {
          final List<Task> tasks = await StorageService.loadTasks();
          final int index = tasks.indexWhere((t) => t.id == oldTask.id);
          if (index != -1) {
            tasks[index] = updatedTask;
            await StorageService.saveTasks(tasks);
            loadTasks();
          }
          Navigator.pop(context);
        },
        onDelete: () async {
          deleteTask(oldTask);
          Navigator.pop(context);
        },
      ),
    );
  }

  void addTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewTaskScreen(
          onSave: (newTask) async {
            final List<Task> tasks = await StorageService.loadTasks();
            tasks.add(newTask);
            await StorageService.saveTasks(tasks);
            loadTasks();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Study Planner")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: selectedDate,
            eventLoader: (day) => getTasksForDay(day),
            selectedDayPredicate: (day) =>
                day.year == selectedDate.year &&
                day.month == selectedDate.month &&
                day.day == selectedDate.day,
            onDaySelected: (selected, focused) {
              setState(() => selectedDate = selected);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (getTasksForDay(day).isNotEmpty) {
                  return const Positioned(
                    bottom: 1,
                    child: Icon(Icons.circle, size: 8, color: Colors.purple),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: getTasksForDay(selectedDate).isEmpty
                ? const Center(child: Text("No tasks for this day!"))
                : ListView.builder(
                    itemCount: getTasksForDay(selectedDate).length,
                    itemBuilder: (context, index) {
                      final Task task = getTasksForDay(selectedDate)[index];
                      return TaskTile(
                        task: task,
                        onToggleDone: (val) => toggleTaskDone(task, val),
                        onEdit: () => editTask(task),
                        onDelete: () => deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) Navigator.pushReplacementNamed(context, '/today');
          if (idx == 1) return;
          if (idx == 2) Navigator.pushReplacementNamed(context, '/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
