class TaskHistory {
  final int id;          // Primary key (auto-incremented)
  final int taskId;     // Foreign key referencing the task
  final String taskTitle; // Title of the task
  final String date;     // Date of the task
  final int duration;    // Duration in minutes
  final int status;      // Status of the task

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.date,
    required this.duration,
    required this.status,
  });

  // Factory method to create a TaskHistory object from a map (from the database)
  factory TaskHistory.fromMap(Map<String, dynamic> map) {
    return TaskHistory(
      id: map['id'],              // Get the id from the map
      taskId: map['taskId'],      // Get the taskId from the map
      taskTitle: map['taskTitle'], // Get the taskTitle from the map
      date: map['date'],          // Get the date from the map
      duration: map['duration'],   // Get the duration from the map
      status: map['status'],       // Get the status from the map
    );
  }

  // TaskHistory.fromJson(Map<String, dynamic> map) { 
  //   id: map['id'],              // Get the id from the map
  //   taskId: map['taskId'],      // Get the taskId from the map
  //   taskTitle: map['taskTitle'], // Get the taskTitle from the map
  //   date: map['date'],          // Get the date from the map
  //   duration: map['duration'],   // Get the duration from the map
  //   status: map['status'], 
  // }

  // Method to convert TaskHistory object to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'date': date,
      'duration': duration,
      'status': status,
    };
  }
}
