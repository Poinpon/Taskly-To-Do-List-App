import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:to_do_list_app/models/task_model.dart';
import 'package:to_do_list_app/data/database.dart';
import 'package:to_do_list_app/utils/todo_list.dart';
import 'package:to_do_list_app/Pages/login_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final String username;

  const CategoryPage({
    super.key,
    required this.category,
    required this.username,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ToDoDatabase db = ToDoDatabase();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    db.loadData();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void addTask() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      db.toDoList.add(TaskModel(
        name: _taskController.text.trim(),
        isCompleted: false,
        username: widget.username,
        category: widget.category,
      ));
      _taskController.clear();
    });

    db.updateDatabase();
  }

  void toggleCheckbox(bool? value, int index) {
    setState(() {
      db.toDoList[index].isCompleted = !db.toDoList[index].isCompleted;
    });
    db.updateDatabase();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final isAll = widget.category == 'All Categories';
    final filteredTasks = db.toDoList
        .asMap()
        .entries
        .where((entry) {
      final task = entry.value;
      final matchesCategory = isAll || task.category == widget.category;
      final matchesUser = task.username == widget.username;
      final matchesSearch = task.name.toLowerCase().contains(_searchText);
      return matchesCategory && matchesUser && matchesSearch;
    })
        .map((entry) => {
      "index": entry.key,
      "task": entry.value,
    })
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Log out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await Hive.box('session').delete('loggedInUser');
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.amber.shade50,
              ),
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
              child: Text(
                '📝 No tasks found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                int actualIndex = filteredTasks[index]["index"] as int;
                TaskModel task =
                filteredTasks[index]["task"] as TaskModel;

                return TodoList(
                  taskName: task.name,
                  taskCompleted: task.isCompleted,
                  onChanged: (value) =>
                      toggleCheckbox(value, actualIndex),
                  deleteFunction: (context) => deleteTask(actualIndex),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Add a new task',
                filled: true,
                fillColor: Colors.amber.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
