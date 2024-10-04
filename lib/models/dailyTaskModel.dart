class DailyTaskModel {
  // Define class properties
  int? id;
  String? title;
  int? defaultMinutes;
  int? spentMinutes;
  int? spentHours;
  String? state;
  int? completed;
  String? createDate;

  // Constructor with optional 'id' parameter
  DailyTaskModel(
    this.title, 
    this.defaultMinutes, 
    this.state, 
    this.completed, 
    this.createDate, 
    { this.spentMinutes, 
      this.spentHours, 
      this.id
    });

  // Convert a Note into a Map. The keys must correspond to the names of the
  // columns in the database.
  DailyTaskModel.fromJson(Map<String, dynamic> map) { 
    id = map['id'];
    title = map['title'];
    defaultMinutes = map['defaultMinutes'];
    spentMinutes = map['spentMinutes'];
    spentHours = map['spentHours'];
    state = map['state'];
    completed = map['completed'];
    createDate = map['createDate'];
  }

// Method to convert a 'DailyTaskModel' to a map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'defaultMinutes ': defaultMinutes ,
      'spentMinutes': spentMinutes,
      'spentHours': spentHours,
      'state': state,
      'completed': completed,
      'createDate': createDate,
    };
  }
}