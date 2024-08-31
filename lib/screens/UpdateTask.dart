import 'package:flutter/material.dart';
import 'package:task_master/screens/AppDrawer.dart';

class UpdateTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
      ),
      drawer: Appdrawer(),
    );
  }
}