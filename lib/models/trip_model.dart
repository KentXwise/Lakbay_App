import '../models/member_model.dart';
import '../models/task_model.dart';
import '../models/activity_model.dart'; // Ensure this import exists

class Trip {
  final String id;
  final String title;
  final String destination;
  final String startDate;
  final String endDate;
  final int budget;
  final String image;

  final List<Member> members;
  final List<Activity> activities; // Changed from dynamic to Activity
  final List<Expense> expenses;
  final List<TaskItem> tasks;
  final String? departureTime;
  final String? arrivalTime;

  bool isHovered = false;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.image,
    required this.members,
    List<Activity>? activitiesList,
    List<Expense>? expensesList,
    List<TaskItem>? tasksList,
    this.departureTime,
    this.arrivalTime,
  })  : activities = activitiesList ?? [],
        expenses = expensesList ?? [],
        tasks = tasksList ?? [];

  int getTotalSpent() {
    return expenses.fold(0, (sum, expense) => sum + expense.cost.toInt());
  }

  int getRemaining() {
    return budget - getTotalSpent();
  }

  // --- JSON Serialization for Firestore ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'image': image,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'members': members.map((x) => x.toJson()).toList(),
      'activities': activities.map((x) => x.toJson()).toList(),
      'expenses': expenses.map((x) => x.toJson()).toList(),
      'tasks': tasks.map((x) => x.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      budget: (json['budget'] ?? 0).toInt(),
      image: json['image'] ?? 'assets/images/photo1.jpg',
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      members: json['members'] != null
          ? List<Member>.from(json['members'].map((x) => Member.fromJson(x)))
          : [],
      activitiesList: json['activities'] != null
          ? List<Activity>.from(
              json['activities'].map((x) => Activity.fromJson(x)))
          : [],
      expensesList: json['expenses'] != null
          ? List<Expense>.from(json['expenses'].map((x) => Expense.fromJson(x)))
          : [],
      tasksList: json['tasks'] != null
          ? List<TaskItem>.from(json['tasks'].map((x) => TaskItem.fromJson(x)))
          : [],
    );
  }
}

class Expense {
  final String description;
  final String category;
  final double cost;
  final String date;

  Expense({
    required this.description,
    required this.category,
    required this.cost,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'category': category,
    'cost': cost,
    'date': date,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      cost: (json['cost'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}