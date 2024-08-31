import 'package:flutter/material.dart';
import 'package:task_master/screens/AppDrawer.dart';

class Calender extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calender'),
      ),
      drawer: Appdrawer(),
    );
  }
}