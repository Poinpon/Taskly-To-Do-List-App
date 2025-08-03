import 'package:hive/hive.dart';

part 'task_model.g.dart'; // Needed for generated code

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String username;

  @HiveField(3)
  String category;

  TaskModel({
    required this.name,
    this.isCompleted = false,
    required this.username,
    this.category = 'General',
  });
}