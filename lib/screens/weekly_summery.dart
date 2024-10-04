import 'package:flutter/material.dart';
import 'package:task_master/models/dailyTaskModel.dart';
import '../services/DatabaseHelper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:task_master/models/task_history_model.dart';

class WeeklySummery extends StatefulWidget {

  @override
  State<WeeklySummery> createState() => _WeeklySummeryState();
}

class _WeeklySummeryState extends State<WeeklySummery> {

  DatabaseHelper taskDatabase = DatabaseHelper.instance;
  List<DailyTaskModel> tasks = [];

  late Future<List<Map<String, dynamic>>> _taskHistoryFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch data
    _taskHistoryFuture = DatabaseHelper.instance.getTaskHistory();
    refreshTasks();
  }

  Future<void> refreshTasks() async {
    final value = await taskDatabase.getAll();
    setState(() {
      tasks = value;
    });
    await getCurrentWeekDates();
    await calPercentage();
  }

  String getDayNameFromString(String dateString) {
    DateTime date = DateTime.parse(dateString);  // Parse the string into a DateTime object
    String dayName = DateFormat('EEEE').format(date);  // Get the full day name
    return dayName;  // Return the day name as a string
  }

  List<String> weekDates = [];

  Future<void> getCurrentWeekDates() async{
    DateTime today = DateTime.now();
    int currentDay = today.weekday; 
    DateTime sunday = today.subtract(Duration(days: currentDay % 7));
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    // Clear the weekData map before populating it
    weekData.clear();

    // Populate the global weekDates list
    for (int i = 0; i < 7; i++) {
      DateTime day = sunday.add(Duration(days: i));
      String formattedDate = dateFormat.format(day);
      weekDates.add(formattedDate);
    }
  }

  List<double> weekPrcntg = List<double>.filled(7, 0); // Initialize with 7 zeros
  Map<String, List<TaskHistory?>> weekData = {}; // Map to store task history for each day
  
  Future<void> calPercentage() async {
    for (String dateString in weekDates) {
      List<TaskHistory?> historyList = await taskDatabase.getTaskHistoryByDate(dateString);
      weekData[dateString] = historyList;  // Store task history
    }
    // Ensure the UI is updated after calculating the weekData
    setState(() {
      displayWeekData();  // Call this to calculate and store the percentage
    });
  }

  Future<void> displayWeekData() async {
    int i = 0;
    if (weekData.isNotEmpty) {
      weekData.forEach((dateString, taskHistoryList) {
        double total = 0;
        double done = 0;
        for (var history in taskHistoryList) {
          // if()
          if (history != null) {
            if (history.status == 1) {
              done += history.duration;
            }
            total += history.duration;
          }
        }

        if (total > 0) {
          weekPrcntg[i] = double.parse(((done / total) * 100).toStringAsFixed(2));  // Store percentage
        } else {
          weekPrcntg[i] = 0;  // Set 0% if no tasks
        }
        i++;
      });

      // Trigger a rebuild after weekPrcntg is calculated
      setState(() {});
    }
  }

  Widget buildTaskCard(List<TaskHistory?> taskList, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),  // Margin between cards
      decoration: BoxDecoration(
        color: Colors.tealAccent.shade100,  // Background color for the entire tile
        borderRadius: BorderRadius.circular(12.0),  // Rounded corners with radius 12
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            blurRadius: 4.0, // Shadow blur radius
            offset: const Offset(2, 2), // Offset of the shadow
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          getDayNameFromString(date),  // Display the date or day (e.g., 'SUNDAY')
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        backgroundColor: Colors.white, // Background color for the expanded content
        children: <Widget>[
          if (taskList.isNotEmpty)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 200,  // Limit the height of the content
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: taskList.map((task) {
                    if (task != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.taskTitle,  // Display task title
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${task.duration} mins',  // Display task duration
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  task.status == 1 ? '✔️' : '❌',  // Display status
                                  style: const TextStyle(fontSize: 16, color: Colors.green),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1, color: Colors.grey), // Divider line between tasks
                          ],
                        ),
                      );
                    } else {
                      return const Text('No tasks available');
                    }
                  }).toList(),
                ),
              ),
            )
          else
            const ListTile(
              title: Text('No task history available', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;  // Get the height of the screen
    // final screenWidth = MediaQuery.of(context).size.width;    // Get the width of the screen

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Summary',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.cyan[700],
          ),
        ),
      ),
      body: SingleChildScrollView(  // Allow the entire body to scroll
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.35,  // Set a maximum height for the chart
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: const TextStyle(
                      fontSize: 18,  // Increased font size for better visibility
                      color: Colors.teal,  // Changed label color to teal
                      fontWeight: FontWeight.bold,  // Bold font for emphasis
                    ),
                    labelRotation: 0,  // Keeps X-axis labels horizontal
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 100, // Y-axis for percentages
                    interval: 20,
                    labelFormat: '{value}%', // Format for percentage display
                    labelStyle: const  TextStyle(
                      fontSize: 16,  // Increased font size for better visibility
                      color: Colors.teal,  // Changed label color to teal
                      fontWeight: FontWeight.bold,  // Bold font for emphasis
                    ),
                  ),
                  series: <ChartSeries>[
                    ColumnSeries<ChartData, String>(
                      dataSource: [
                        ChartData('SUN', weekPrcntg.length > 0 ? weekPrcntg[0] : 0),
                        ChartData('MON', weekPrcntg.length > 1 ? weekPrcntg[1] : 0),
                        ChartData('TUES', weekPrcntg.length > 2 ? weekPrcntg[2] : 0),
                        ChartData('WED', weekPrcntg.length > 3 ? weekPrcntg[3] : 0),
                        ChartData('THU', weekPrcntg.length > 4 ? weekPrcntg[4] : 0),
                        ChartData('FRI', weekPrcntg.length > 5 ? weekPrcntg[5] : 0),
                        ChartData('SAT', weekPrcntg.length > 6 ? weekPrcntg[6] : 0),
                      ],
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      color: Colors.tealAccent.shade200,  // Lighter shade for the column
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        textStyle: TextStyle(
                          fontSize: 16,  // Increased font size for data labels
                          color: Colors.black,
                          fontWeight: FontWeight.w600,  // Slightly bold data labels
                        ),
                      ),
                      dataLabelMapper: (ChartData data, _) => '${data.y}%', // Append '%' to data label
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: Colors.tealAccent.shade200,  // Tooltip background color
                    textStyle: const TextStyle(
                      color: Colors.white,  // Tooltip text color
                      fontWeight: FontWeight.bold,  // Bold tooltip text
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Task List Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.55,  // Set a maximum height for the task list
                ),
                child: SingleChildScrollView(  // Allow the content to scroll
                  child: Column(
                    children: weekData.entries.map((entry) {
                      return buildTaskCard(entry.value, entry.key);  // Passing taskList and the date
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}