import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  static Future<void> saveTasks(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonTasks = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList(_tasksKey, jsonTasks);
  }

  static Future<List<Task>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonTasks = prefs.getStringList(_tasksKey);
    if (jsonTasks == null) return [];
    return jsonTasks
        .map((taskStr) => Task.fromJson(jsonDecode(taskStr)))
        .toList();
  }
}
