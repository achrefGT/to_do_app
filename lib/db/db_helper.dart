import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_app/models/task.dart';
import 'dart:math';



class DBHelper {
  static CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  static int generateIntId() {
    // Get current timestamp in milliseconds
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Generate a random number between 0 and 9999
    int random = Random().nextInt(10000);

    // Concatenate timestamp and random number
    // to ensure uniqueness of the ID
    String idString = '$timestamp$random';

    // Convert the concatenated string to an integer
    int id = int.parse(idString);

    return id;
  }

  static Future<int?> insert(Task task) async {
    try {
      // Generate a unique ID for the task
      int taskId = generateIntId();

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





  static Future<List<Map<String, dynamic>>> query(bool urgent) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        // User is authenticated, proceed to query tasks
        String userId = user.uid;
        QuerySnapshot querySnapshot;

        if (urgent) {
          // Query urgent tasks (color = 2)
          querySnapshot = await _tasksCollection
              .where('userId', isEqualTo: userId)
              .where('color', isEqualTo: 1)
              .get();
        } else {
          // Query all tasks for the user
          querySnapshot = await _tasksCollection
              .where('userId', isEqualTo: userId)
              .get();
        }

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