import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:task_master/screens/AddTask.dart';
import 'package:task_master/screens/AppDrawer.dart';
import 'package:task_master/models/dailyTaskModel.dart';
import 'package:task_master/services/DailyTaskHelper.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  DailyTaskHelper taskDatabase = DailyTaskHelper.instance;
  List<DailyTaskModel> tasks = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<DailyTaskModel> filteredTasks = [];
  bool taskStatus = false;

  @override
  void initState() {
    refreshTasks();
    search();
    super.initState();
  }

  @override
  dispose() {
    // Close the database when no longer needed
    taskDatabase.close();
    super.dispose();
  }

  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          // Perform filtering and update the filteredTasks list
          filteredTasks = tasks.where((task) {
            return task.title!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          // Clear the filteredTasks list
          filteredTasks.clear();
        }
      });
    });
  }

  
  Future<void> updateTaskStatus(int taskId, int isCompleted) async {
    try {
      await taskDatabase.updateTaskStatus(taskId, isCompleted);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompleted == 0 ? "Marked as incomplete" : 'Marked as complete'),
          backgroundColor: Color.fromARGB(255, 53, 162, 208),
        ),
      );

      refreshTasks();
    } catch (error) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task failed to update"),
          backgroundColor: Color.fromARGB(255, 235, 108, 108),
        ),
      );
      if (kDebugMode) {
        print(error);
      }
    }
  }

  taskDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask(taskId: id))
    );
    refreshTasks();
  }

  refreshTasks() {
    taskDatabase.getAll().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }
  
  Widget buildTaskCard(DailyTaskModel task) {
    return Card(
      child: GestureDetector(
        onTap: () => {
          taskDetailsView(id: task.id),
        },
        child: ListTile(
          leading: const Icon(
            Icons.task,
            color: Color.fromARGB(255, 253, 237, 89),
          ),
          title: Text(task.title ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  updateTaskStatus(task.id!, (task.completed == 1) ? 0 : 1);
                },
                icon: Icon(
                  (task.completed == 1) ? Icons.done : Icons.pending,
                  color: (task.completed == 1) ? Color.fromARGB(255, 21, 255, 0) : Color.fromARGB(255, 255, 81, 0) ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Master',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      drawer: Appdrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Tasks...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (isSearchTextNotEmpty) 
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // Clear the search text and update the UI
                      searchController.clear();
                      // Reset the filteredTasks list and refresh the original notes
                      filteredTasks.clear();
                      refreshTasks();
                    },
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: tasks.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Text(
                            "No tasks to display",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            if (isSearchTextNotEmpty)
                              filteredTasks.isNotEmpty
                                ? Column(
                                    children: filteredTasks.map((task) => buildTaskCard(task)).toList(),
                                  )
                                : const Text('No Result found')
                            else
                              Column(
                                children: tasks.map((task) => buildTaskCard(task)).toList(),
                              ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddTask())
          );
        },
        tooltip: 'Create task',
        child: const Icon(Icons.add),
      ),
    );
  }
}