import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:task_master/screens/AddTask.dart';
// import 'package:task_master/screens/AppDrawer.dart';
import 'package:task_master/models/dailyTaskModel.dart';
import 'package:task_master/screens/Overview.dart';
// import 'package:task_master/services/DailyTaskHelper.dart';
import '../services/DatabaseHelper.dart';
import 'package:task_master/screens/Calender.dart';
import 'package:task_master/screens/UpdateTask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  // For date formatting

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  DatabaseHelper taskDatabase = DatabaseHelper.instance;
  List<DailyTaskModel> tasks = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<DailyTaskModel> filteredTasks = [];
  bool taskStatus = false;

  // @override
  // void initState() {
  //   refreshTasks();
  //   _checkAndStoreTasks();
  //   search();
  //   super.initState();
  // }

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  Future<void> refreshTasks() async {
    final value = await taskDatabase.getAll();
    setState(() {
      tasks = value;
    });
  }


  Future<void> _initializeTasks() async {
    await refreshTasks(); // Ensure refreshTasks completes first
    await search();
    await _checkAndStoreTasks(); // Runs only after refreshTasks is done
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
                    .contains(searchController.text.toLowerCase()) &&
                    (task.state == 'active');
          }).toList();
        } else {
          // Clear the filteredTasks list
          filteredTasks.clear();
        }
      });
    });
  }

  Future<void> _checkAndStoreTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastStoredDate = prefs.getString('lastStoredDate');
    
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime threeAM = DateTime(today.year, today.month, today.day, 3, 0, 0);

    // If current time is before 3 AM, consider it as the previous day
    if (now.isBefore(threeAM)) {
      today = today.subtract(Duration(days: 1));
    }

    if (lastStoredDate != null) {
      DateTime lastStored = DateFormat('yyyy-MM-dd').parse(lastStoredDate);

      // Store task data if last stored date is not today and the current time is past 3 AM
      if (!isSameDay(lastStored, today) && now.isAfter(threeAM)) {
        await _storeTaskDataForYesterday(today);
        await prefs.setString('lastStoredDate', DateFormat('yyyy-MM-dd').format(today));
      }
    } else {
      // No previous date stored, store task data if the current time is past 3 AM and save today's date
      if (now.isAfter(threeAM)) {
        await _storeTaskDataForYesterday(today);
        await prefs.setString('lastStoredDate', DateFormat('yyyy-MM-dd').format(today));
      }
    }
  }
  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
  }
  Future<void> _storeTaskDataForYesterday(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    
    for (var task in tasks) {
      if(task.state == 'active' && task.completed == 1) {
        await taskDatabase.storeTaskHistory({
          'taskId': task.id,
          'date': dateString,
          'duration': task.defaultMinutes,
          'status': task.completed,
        });
      } 
    }

    // Update the last stored date to today
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('lastStoredDate', todayDate);

    // Feedback to show that the task has been stored
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${tasks}Tasks stored for yesterday")),
    );
  }
  
  Future<void> updateTaskStatus(int taskId, int isCompleted) async {
    try {
      await taskDatabase.updateTaskStatus(taskId, isCompleted);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // Dismiss the current SnackBar (if any) before showing a new one
      scaffoldMessenger.hideCurrentSnackBar();
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompleted == 0 ? "Marked as incomplete" : 'Marked as complete',
          style: const TextStyle(
            color: Colors.black,
          ),
          ),
          backgroundColor: Colors.cyan[400],
          duration: const Duration(seconds: 2),
        ),
      );

      refreshTasks();
    } catch (error) {
      // Show error feedback
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // Dismiss the current SnackBar (if any) before showing a new one
      scaffoldMessenger.hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        
        const SnackBar(
          content: Text("Task failed to update"),
          backgroundColor: Color.fromARGB(255, 235, 108, 108),
          duration: Duration(seconds: 2),
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

  
  Widget buildTaskCard(DailyTaskModel task) {
    return task.state == 'active' ? Card(
      // color: const Color.fromARGB(255, 230, 245, 247),
      child: GestureDetector(
        onTap: () => {
          taskDetailsView(id: task.id),
        },
        child: ListTile(
          
          leading: Icon(
            Icons.task,
            color: Colors.cyan[500],
          ),
          title: Text(task.title ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    // color: Color.fromRGBO(38, 198, 218, 1),
                  ),
                ),
          subtitle: Text(
                '${task.defaultMinutes ?? ""} min',
                style: const TextStyle(
                  // fontSize
                  color: Colors.blue,
                  ),
              ),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  updateTaskStatus(task.id!, (task.completed == 1) ? 0 : 1);
                },
                tooltip: (task.completed == 1) ? 'mark as uncompleted' : 'mark as completed',
                icon: Icon(
                  (task.completed == 1) ? Icons.task_alt : Icons.pending,
                  size: 25,
                  color: (task.completed == 1) ? Color.fromARGB(255, 21, 255, 0) : Color.fromARGB(255, 70, 170, 252) ,
                ),
              ),
            ],
          ),
        ),
      ),
    ) : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder( // Use Builder to get the correct context
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded,
              color: Colors.cyan[700],
              size: 28,
              // weight: 40,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer when pressed
            },
          ),
        ),
        title: Text('Your Routine',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.cyan[700],
          ),
        ),
      ),
      drawer: Drawer(
        // shadowColor: Color.fromRGBO(0, 151, 167, 1),
        width: 270,
        child: ListView(
          children: [
            SizedBox(
              height: 105,
              child: DrawerHeader(
              decoration: const BoxDecoration(
                // color: Colors.blue,
                
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/taskIcon.png', // Your image path here
                    width: 30, // Customize the width and height as needed
                    height: 30,
                    fit: BoxFit.cover, // Adjust image fit to your preference
                  ),
                  const SizedBox(width: 6,),
                  Text('Task Tracker',
                    style: TextStyle(
                      color: Colors.cyan[700],
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                color: Colors.cyan[500],
                size: 26,
              ),
              title: Text('Home',
                style: TextStyle(
                  // color: Color.fromRGBO(0, 170, 185, 1),
                  color: Colors.cyan[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month,
                color: Colors.cyan[500],
                size: 26,
              ),
              title: Text('Calender',
              style: TextStyle(
                  color: Colors.cyan[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => Calendar())
                ).then((value) {
                // This will run after returning from HomePage (after pop)
                  refreshTasks(); // Call the refresh task function
                });
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.add_box_outlined,
            //     color: Color.fromRGBO(0, 170, 185, 1),
            //     size: 26,
            //   ),
            //   title: const Text('Add New Task',
            //   style: TextStyle(
            //       color: Color.fromRGBO(0, 170, 185, 1),
            //       fontSize: 18,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => AddTask())
            //     ).then((value) {
            //     // This will run after returning from HomePage (after pop)
            //       refreshTasks(); // Call the refresh task function
            //     });
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.edit_note,
                color: Colors.cyan[500],
                size: 26,
              ),
              title: Text('Update Routine',
              style: TextStyle(
                  color: Colors.cyan[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateTask())
                ).then((value) {
                // This will run after returning from HomePage (after pop)
                  refreshTasks(); // Call the refresh task function
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.pie_chart,
                color: Colors.cyan[500],
                size: 26,
              ),
              title: Text('Overview',
              style: TextStyle(
                  color: Colors.cyan[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Overview())
                ).then((value) {
                // This will run after returning from HomePage (after pop)
                  refreshTasks(); // Call the refresh task function
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.restart_alt,
                color: Colors.cyan[500],
                size: 26,
              ),
              title: Text('Reset Routine',
              style: TextStyle(
                  color: Colors.cyan[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Navigator.of(context).pop();
                // Navigator.push(context,
                //   MaterialPageRoute(builder: (context) => Overview())
                // ).then((value) {
                // // This will run after returning from HomePage (after pop)
                //   refreshTasks(); // Call the refresh task function
                // });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Tasks...',
                      prefixIcon: Icon(Icons.search,
                        color: Colors.cyan[600],
                        size: 30,
                      ),
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
          ).then((value) {
          // This will run after returning from HomePage (after pop)
            refreshTasks(); // Call the refresh task function
          });
        },
        tooltip: 'Create task',
        child: const Icon(Icons.add),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //       _checkAndStoreTasks();
      //   },
      //   tooltip: 'Upload',
      //   child: const Icon(Icons.upload),
      // ),
    );
  }
}