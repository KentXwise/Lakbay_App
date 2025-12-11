class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String? dueDate;
  final String? assignedTo;
  final bool isCompleted;
  final int priority;

  TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.assignedTo,
    this.isCompleted = false,
    this.priority = 1,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? assignedTo,
    bool? isCompleted,
    int? priority,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'assignedTo': assignedTo,
    'isCompleted': isCompleted,
    'priority': priority,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'],
      assignedTo: json['assignedTo'],
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 1,
    );
  }
}