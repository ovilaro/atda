import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  final List<TodoModel> _tasks = [];

  int _counter = 0;

  List<TodoModel> get tasks => List.unmodifiable(_tasks);

  List<TodoModel> get activeTasks => _tasks.where((t) => !t.completed && !t.deleted).toList();

  List<TodoModel> get completedTasks => _tasks.where((t) => t.completed && !t.deleted).toList();

  List<TodoModel> get deletedTasks {
    final d = _tasks.where((t) => t.deleted).toList();
    d.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
    return d;
  }

  void addTask(String text) {
    if (text.trim().isEmpty) return;
    _counter++;
    final id = '$_counter';
    _tasks.insert(0, TodoModel(id: id, text: text, isToday: false));
    notifyListeners();
  }

  void reorderActiveTask(int oldIndex, int newIndex) {
    final activeIds = activeTasks.map((t) => t.id).toList();
    if (oldIndex < 0 || oldIndex >= activeIds.length) return;
    if (newIndex < 0 || newIndex >= activeIds.length) return;
    if (oldIndex == newIndex) return;

    final id = activeIds.removeAt(oldIndex);
    activeIds.insert(newIndex, id);

    final newActive = activeIds.map((id) => _tasks.firstWhere((t) => t.id == id)).toList();
    final nonActive = _tasks.where((t) => t.completed || t.deleted).toList();

    _tasks
      ..clear()
      ..addAll(newActive)
      ..addAll(nonActive);
    notifyListeners();
  }

  void toggleCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = TodoModel(
        id: task.id,
        text: task.text,
        completed: !task.completed,
        isToday: task.isToday,
        deleted: task.deleted,
        deletedAt: task.deletedAt,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = TodoModel(
        id: task.id,
        text: task.text,
        completed: task.completed,
        isToday: task.isToday,
        deleted: true,
        deletedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void restoreTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = TodoModel(
        id: task.id,
        text: task.text,
        completed: task.completed,
        isToday: task.isToday,
        deleted: false,
        deletedAt: null,
      );
      notifyListeners();
    }
  }

  void updateTaskText(String id, String text) {
    if (text.trim().isEmpty) return;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = TodoModel(
        id: task.id,
        text: text,
        completed: task.completed,
        isToday: task.isToday,
        deleted: task.deleted,
        deletedAt: task.deletedAt,
      );
      notifyListeners();
    }
  }

  void toggleToday(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = TodoModel(
        id: task.id,
        text: task.text,
        completed: task.completed,
        isToday: !task.isToday,
        deleted: task.deleted,
        deletedAt: task.deletedAt,
      );
      notifyListeners();
    }
  }
}

class TodoModel extends Equatable {
  final String id;
  final String text;
  final bool completed;
  final bool isToday;
  final bool deleted;
  final DateTime? deletedAt;

  const TodoModel({
    required this.id,
    required this.text,
    this.completed = false,
    this.isToday = false,
    this.deleted = false,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, text, completed, isToday, deleted, deletedAt];
}