import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_bottom_sheet.dart';
import 'new_task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<Task> tasks = [];
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
    _initNotifications();
  }

  void loadTasks() async {
    List<Task> allTasks = await StorageService.loadTasks();
    setState(() {
      tasks = allTasks
          .where(
            (task) =>
                task.dueDate.year == DateTime.now().year &&
                task.dueDate.month == DateTime.now().month &&
                task.dueDate.day == DateTime.now().day,
          )
          .toList();
    });
  }

  Future<void> _initNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _scheduleInAppAlerts();
  }

  void _scheduleInAppAlerts() {
    if (!notificationsEnabled) return;
    final now = DateTime.now();
    for (final task in tasks) {
      if (task.reminderTime != null && task.reminderTime!.isAfter(now)) {
        final duration = task.reminderTime!.difference(now);
        Future.delayed(duration, () {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Reminder: ${task.title}')));
        });
      }
      if (task.notifyDayBefore) {
        final DateTime dayBefore = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        ).subtract(const Duration(days: 1));
        if (dayBefore.isAfter(now)) {
          Future.delayed(dayBefore.difference(now), () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Due tomorrow: ${task.title}')),
            );
          });
        }
      }
      if (task.notifyHourBefore) {
        final DateTime hourBefore = task.dueDate.subtract(
          const Duration(hours: 1),
        );
        if (hourBefore.isAfter(now)) {
          Future.delayed(hourBefore.difference(now), () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Due in 1 hour: ${task.title}')),
            );
          });
        }
      }
    }
  }

  Future<void> deleteTask(Task task) async {
    List<Task> allTasks = await StorageService.loadTasks();
    allTasks.removeWhere((t) => t.id == task.id);
    await StorageService.saveTasks(allTasks);
    loadTasks();
  }

  void editTask(Task oldTask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskBottomSheet(
        task: oldTask,
        onSave: (updatedTask) async {
          List<Task> allTasks = await StorageService.loadTasks();
          int index = allTasks.indexWhere((t) => t.id == oldTask.id);
          if (index != -1) {
            allTasks[index] = updatedTask;
          }
          await StorageService.saveTasks(allTasks);
          loadTasks();
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
            List<Task> allTasks = await StorageService.loadTasks();
            allTasks.add(newTask);
            await StorageService.saveTasks(allTasks);
            loadTasks();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void toggleTaskDone(Task task, bool value) async {
    List<Task> allTasks = await StorageService.loadTasks();
    int index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      allTasks[index] = allTasks[index].copyWith(isDone: value);
      await StorageService.saveTasks(allTasks);
      loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today")),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks today!"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskTile(
                task: tasks[index],
                onToggleDone: (val) => toggleTaskDone(tasks[index], val),
                onEdit: () => editTask(tasks[index]),
                onDelete: () => deleteTask(tasks[index]),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 0) return;
          if (idx == 1) Navigator.pushReplacementNamed(context, '/calendar');
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
