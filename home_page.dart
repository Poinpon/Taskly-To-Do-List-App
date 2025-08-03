import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:to_do_list_app/data/database.dart';
import 'package:to_do_list_app/models/task_model.dart';
import 'package:to_do_list_app/utils/todo_list.dart';
import 'login_page.dart';
import 'package:to_do_list_app/pages/category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ToDoDatabase db = ToDoDatabase();

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  List<String> categories = ['General', 'Work', 'School'];
  String selectedCategory = 'General';

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
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index].isCompleted = !db.toDoList[index].isCompleted;
    });
    db.updateDatabase();
  }

  void saveNewTask() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      db.toDoList.add(TaskModel(
        name: _controller.text.trim(),
        isCompleted: false,
        username: db.currentUser,
        category: selectedCategory,
      ));
      _controller.clear();
    });
    db.updateDatabase();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  void logout() {
    Hive.box('session').delete('loggedInUser');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = [];
    for (int i = 0; i < db.toDoList.length; i++) {
      var task = db.toDoList[i];
      if (task.name.toLowerCase().contains(_searchText)) {
        filteredList.add({"index": i, "task": task});
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Tasks'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          category: cat,
                          username: db.currentUser,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
              child: Text(
                '📝 Ready to add a new task?',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                int actualIndex = filteredList[index]["index"];
                TaskModel task = filteredList[index]["task"];

                return TodoList(
                  taskName: task.name,
                  taskCompleted: task.isCompleted,
                  onChanged: (value) =>
                      checkBoxChanged(value, actualIndex),
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
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a new todo item',
                filled: true,
                fillColor: Colors.amber.shade50,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((cat) =>
                  DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: const TextStyle(color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: saveNewTask,
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
