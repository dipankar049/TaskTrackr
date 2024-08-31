import 'package:flutter/material.dart';
import 'package:task_master/screens/AddTask.dart';
import 'package:task_master/screens/Calender.dart';
import 'package:task_master/screens/HomePage.dart';
import 'package:task_master/screens/UpdateTask.dart';

class Appdrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Task Master'),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => HomePage())
              );
            },
          ),
          ListTile(
            title: const Text('Calender'),
            onTap: () {
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => Calender())
              );
            },
          ),
          ListTile(
            title: const Text('Add New Task'),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTask())
              );
            },
          ),
          ListTile(
            title: const Text('Update Task'),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => UpdateTask())
              );
            },
          ),
        ],
      ),
    );
  }
}