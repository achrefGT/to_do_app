import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_app/db/db_helper.dart';

import '../models/task.dart';

final taskController = Provider((ref) => TaskController());

final getTasksController = FutureProvider<List<Task>?>((ref) {
  final tasks = ref.read(taskController).getTasks();
  return tasks;
});


class TaskController {
  var taskList = <Task>[];

  Future<int?> addTask({Task? task}) async {
    return await DBHelper.insert(task!);
  }

  Future<List<Task>> getTasks() async {
    try {
      List<Map<String, dynamic>> result = await DBHelper.query(false);
      final tasks = result.map((data) => Task.fromMap(data)).toList();
      return tasks;
    } catch (e) {
      print("Error fetching tasks from local database: $e");
      return []; // Return an empty list in case of error
    }
  }



  void delete(Task task) async {
    await DBHelper.delete(task);
  }

  void update(Task task) async {
    await DBHelper.update(task);
  }

  Future<List<Task>> getUrgentTasks() async {
    try {
      List<Map<String, dynamic>> result = await DBHelper.query(true);
      final tasks = result.map((data) => Task.fromMap(data)).toList();
      return tasks;
    } catch (e) {
      print("Error fetching urgent tasks from database: $e");
      return []; // Return an empty list in case of error
    }
  }

}
