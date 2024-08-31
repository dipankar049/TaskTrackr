import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:task_master/screens/AppDrawer.dart';
import 'package:task_master/models/dailyTaskModel.dart';
import 'package:task_master/screens/HomePage.dart';
import 'package:task_master/services/DailyTaskHelper.dart';
// import 'package:intl/intl.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.taskId});  
  final int? taskId;

  @override
  State<AddTask> createState() => _AddTaskState();

}

class _AddTaskState extends State<AddTask> {

  final formKey = GlobalKey<FormState>();

  // Create an instance of the database helper
  DailyTaskHelper taskDatabase = DailyTaskHelper.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController defaultMinutesController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  late DailyTaskModel task;
  bool isLoading = false;
  bool isNewTask = false;

  @override
  void initState() {
    refreshTasks();
    super.initState();
  }

  insert(DailyTaskModel model) {
    taskDatabase.insert(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Task successfully added."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.push(context, 
        MaterialPageRoute(builder: (context) => HomePage())
      );
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Task failed to save."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  createTask() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();

      DailyTaskModel model =
        DailyTaskModel(titleController.text, int.tryParse(defaultMinutesController.text), 'active', 0);

      if (isNewTask) {
        insert(model);
      } 
      else {
        model.id = task.id;
        update(model);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  update(DailyTaskModel model) {
    taskDatabase.update(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("task successfully updated."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("task failed to update."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  refreshTasks() {
    if (widget.taskId == null) {
      setState(() {
        isNewTask = true;
      });
      return;
    }
    taskDatabase.read(widget.taskId!).then((value) {
      setState(() {
        task = value;
        titleController.text = task.title!;
        defaultMinutesController.text = task.defaultMinutes!.toString();
      });
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          isNewTask
              ? 'Add New Task'
              : 'Edit Task', // Set title to 'Add a task' if isNewTask is true, otherwise set it to 'Edit task'
        ),
      ),
      drawer: Appdrawer(),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter task",
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )),
                    ),
                    // validator: validateTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Description Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: defaultMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter duration/day(in minutes)",
                      labelText: 'Duration(in minutes)',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: createTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Text(
                      isNewTask
                        ? 'Add'
                        : 'Update', 
                    style: TextStyle(
                      color: Color.fromARGB(142, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10.0),
                  child: Visibility(
                    visible:
                        !isNewTask, // Set this to determine if the button should be visible
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 235, 108, 108),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}