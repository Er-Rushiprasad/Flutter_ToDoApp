import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TaskService {
  Future<void> addTask(String taskName, String dueDate) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/tasks/add');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"taskName": taskName, "dueDate": dueDate}),
      );

      if (kDebugMode) {
        if (kDebugMode) {
          print('Response status: ${response.statusCode}');
        }
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Task added successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to add task');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}
