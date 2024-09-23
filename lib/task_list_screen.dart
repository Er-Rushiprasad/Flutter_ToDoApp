import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final String backendUrl = 'http://10.0.2.2:8080'; // Replace with your backend URL

  // Fetch tasks from backend
  Future<void> _fetchTasks() async {
    final response = await http.get(Uri.parse('$backendUrl/tasks'));
    if (response.statusCode == 200) {
      setState(() {
        _tasks.clear();
        List<dynamic> tasksFromServer = json.decode(response.body)['content'];
        for (var task in tasksFromServer) {
          _tasks.add({
            'id': task['id'],
            'description': task['description'],
            'completed': task['completed']
          });
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load tasks');
      }
    }
  }

  // Add new task
  Future<void> _addTask(String description) async {
    final response = await http.post(
      Uri.parse('$backendUrl/tasks/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description, "completed": false}),
    );
    if (response.statusCode == 200) {
      _fetchTasks(); // Refresh the task list after adding
    } else {
      if (kDebugMode) {
        print('Failed to add task');
      }
    }
  }

  // Update task completion status
  Future<void> _updateTaskCompletion(int id, bool completed, String description) async {
    final response = await http.put(
      Uri.parse('$backendUrl/tasks/update/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "description": description, "completed": completed}),
    );
    if (response.statusCode == 200) {
      _fetchTasks(); // Refresh the task list after updating
    } else {
      if (kDebugMode) {
        print('Failed to update task');
      }
    }
  }


// Delete task
  Future<void> _deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$backendUrl/tasks/delete/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _tasks.removeWhere((task) => task['id'] == id); // Remove the task from the list
      });
    }
    else {
      if (kDebugMode) {
        print('Failed to delete task');
      }
    }
  }


  // Initialize fetching of tasks
  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // Light blue background
      appBar: AppBar(
        title: const Text('Scheduler', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Column(
        children: [
          // White container for the To-Do list title
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.lightBlue[200],
            child: const Center(
              child: Text('To-Do List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          // Task List (Scrollable)
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task['completed'],
                        onChanged: (bool? value) {
                          _updateTaskCompletion(task['id'], value!, task['description']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(task['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Floating action button to add new tasks
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add New Task'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(hintText: "Enter Task Description"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _addTask(_taskController.text);
                        _taskController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add ,size: 35,),
        ),
      ),
    );
  }
}
