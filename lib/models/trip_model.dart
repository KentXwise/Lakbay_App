import '../models/member_model.dart';  
import '../models/task_model.dart';


class Trip {
  final String? id;
  final String title;
  final String destination;
  final String startDate;
  final String endDate;
  final int budget;
  final String image;
  final List<Member> members;  
  final List<dynamic> activities;
  final List<Expense> expenses;
  final List<TaskItem> tasks;
  final String? departureTime;
  final String? arrivalTime;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.image,
    required this.members,
    List<dynamic>? activitiesList,      
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
}
