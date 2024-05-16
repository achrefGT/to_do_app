import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_app/models/task.dart';
import 'dart:math';



class DBHelper {
  static CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  static int _IdCounter = 0;

  static Future<int?> insert(Task task) async {
    try {
      // Generate a unique ID for the task
      int taskId = _IdCounter++;

      // Set the task ID
      task.id = taskId;

      // Add the task to Firestore with the same ID
      await _tasksCollection.doc(taskId.toString()).set(task.toMap());

      print("Task added successfully with ID: $taskId");
      return taskId;
    } catch (e) {
      print("Error adding task: $e");
      return null;
    }
  }





  static Future<List<Map<String, dynamic>>> query() async {
    try {
      // Get the current user ID
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        // User is authenticated, proceed to query tasks
        String userId = user.uid;

        // Query tasks where userId matches the current user's ID
        QuerySnapshot querySnapshot = await _tasksCollection.where('userId', isEqualTo: userId).get();

        // Convert the QuerySnapshot to a List<Map<String, dynamic>>
        return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        // User is not authenticated, handle accordingly
        // For example, return an empty list or show an error message
        return [];
      }
    } catch (e) {
      print("Error querying tasks: $e");
      return []; // Return an empty list in case of error
    }
  }


  static Future<void> delete(Task task) async {
    try {
      // Convert the int id to a string
      String docId = task.id.toString();

      // Update the task in Firestore using the document ID
      await _tasksCollection.doc(docId).delete();

      print("Task deleted successfully with ID: ${task.id}");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  static Future<void> update(Task task) async {
    try {
      // Convert the int id to a string
      String docId = task.id.toString();

      // update the isCompleted field
      await _tasksCollection.doc(docId).update({'isCompleted': true});

      print("Task updated successfully with ID: ${task.id}");
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}