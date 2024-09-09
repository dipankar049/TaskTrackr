import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:task_master/models/dailyTaskModel.dart';
// import 'package:task_master/services/DailyTaskHelper.dart';
// import 'package:intl/intl.dart';
import '../services/DatabaseHelper.dart';

class Overview extends StatefulWidget {

  @override
  State<Overview> createState() => _OverviewState();

}

class _OverviewState extends State<Overview> {

  DatabaseHelper taskDatabase = DatabaseHelper.instance;

  // void fetchAndPrintTaskHistory() async {

  //   // Retrieve all task history
  //   List<Map<String, dynamic>> allTaskHistory = await taskDatabase.getTaskHistory();
    
  //   // Print all task history
  //   for (var record in allTaskHistory) {
  //     int taskId = record['taskId'];
  //     String date = record['date'];
  //     int duration = record['duration'];
  //     int status = record['status'];
      
  //     print('Task ID: $taskId, Date: $date, Duration: $duration, Status: $status');
  //   }
  // }

  // // Fetch history for a specific taskId
  // void fetchHistoryByTaskId(int taskId) async {
  //   DatabaseHelper dbHelper = DatabaseHelper.instance;

  //   // Retrieve task history for a specific taskId
  //   List<Map<String, dynamic>> taskHistory = await dbHelper.getTaskHistoryByTaskId(taskId);
    
  //   // Print the specific task history
  //   for (var record in taskHistory) {
  //     int taskId = record['taskId'];
  //     String date = record['date'];
  //     int duration = record['duration'];
  //     int status = record['status'];
      
  //     print('Task ID: $taskId, Date: $date, Duration: $duration, Status: $status');
  //   }
  // }

  
  late Future<List<Map<String, dynamic>>> _taskHistoryFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch data
    _taskHistoryFuture = DatabaseHelper.instance.getTaskHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Summery',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.cyan[700],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _taskHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No task history available.'));
          } else {
            // Extract data from snapshot
            List<Map<String, dynamic>> taskHistory = snapshot.data!;
            return ListView.builder(
              itemCount: taskHistory.length,
              itemBuilder: (context, index) {
                var record = taskHistory[index];
                return ListTile(
                  title: Text('Task ID: ${record['taskId']}'),
                  subtitle: Text(
                    'Date: ${record['date']}\nDuration: ${record['duration']} minutes\nStatus: ${record['status']}',
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}