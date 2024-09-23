class Task {
  final int id;
  final String description;
  final bool completed;

  Task({
    required this.id,
    required this.description,
    required this.completed,
  });

  // Factory method to create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      completed: json['completed'],
    );
  }
}
