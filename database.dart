import 'package:hive/hive.dart';
import 'package:to_do_list_app/models/task_model.dart';

class ToDoDatabase {
  List<TaskModel> toDoList = [];

  final Box<TaskModel> _myBox = Hive.box<TaskModel>('mybox');
  final Box _sessionBox = Hive.box('session');

  late String currentUser;

  void loadData() {
    currentUser = _sessionBox.get('loggedInUser') ?? '';
    toDoList = _myBox.values
        .where((task) => task.username == currentUser)
        .toList();
  }

  void updateDatabase() {
    if (currentUser.isEmpty) return;

    // Remove old tasks of current user only
    final keysToRemove = _myBox.keys.where((key) {
      final task = _myBox.get(key);
      return task?.username == currentUser;
    }).toList();

    for (var key in keysToRemove) {
      _myBox.delete(key);
    }

    // Save updated tasks for the current user
    for (var task in toDoList) {
      _myBox.add(task);
    }
  }

  void createInitialData() {
    currentUser = _sessionBox.get('loggedInUser') ?? '';
    if (currentUser.isEmpty) return;

    toDoList = [
      TaskModel(name: 'Do CSC264 mobile app', isCompleted: false, username: currentUser),
      TaskModel(name: 'Finish coding for CSC305', isCompleted: false, username: currentUser),
    ];
    updateDatabase();
  }
}