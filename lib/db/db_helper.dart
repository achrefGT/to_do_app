import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_app/models/task.dart';


class DBHelper {
  static CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  static Future<String?> insert(Task task) async {
    try {
      // Generate a unique ID for the task
      String taskId = _tasksCollection.doc().id;

      // Set the task ID
      task.id = taskId;

      // Add the task to Firestore with the same ID
      await _tasksCollection.doc(taskId).set(task.toMap());

      print("Task added successfully with ID: $taskId");
      return taskId;
    } catch (e) {
      print("Error adding task: $e");
      return null;
    }
  }





  static Future<List<Map<String, dynamic>>> query() async {
    try {
      QuerySnapshot querySnapshot = await _tasksCollection.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error querying tasks: $e");
      return []; // Return an empty list in case of error
    }
  }


  static Future<void> delete(Task task) async {
    try {
      await _tasksCollection.doc(task.id as String?).delete();
      print("Task deleted successfully.");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  static Future<void> update(String id) async {
    try {
      await _tasksCollection.doc(id).update({'isCompleted': true});
      print("Task updated successfully.");
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}