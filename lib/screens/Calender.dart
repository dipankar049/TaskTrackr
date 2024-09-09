// ignore: file_names
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/calenderTaskModel.dart';
import '../services/DatabaseHelper.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<Calendar> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.cyan[700],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: 
        FutureBuilder<List<Meeting>>(
          future: _databaseHelper.getMeetings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SfCalendar(
                view: CalendarView.month,
                onLongPress: calendarTapped,
                dataSource: MeetingDataSource([]),
                initialSelectedDate: DateTime.now(),
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                ),
              );
            } else {
              return SfCalendar(
                view: CalendarView.month,
                onLongPress: calendarTapped,
                dataSource: MeetingDataSource(snapshot.data!),
                initialSelectedDate: DateTime.now(),
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void calendarTapped(CalendarLongPressDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      _showAddEventDialog(details.date!);
    }
  }

  void _showAddEventDialog(DateTime selectedDate) {
    final eventNameController = TextEditingController();
    DateTime fromDate = selectedDate;
    DateTime toDate = selectedDate.add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text('From: ${fromDate.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fromDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => fromDate = picked);
                },
              ),
              ListTile(
                title: Text('To: ${toDate.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: toDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => toDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (eventNameController.text.isNotEmpty) {
                  final newMeeting = Meeting(
                    eventName: eventNameController.text,
                    from: fromDate,
                    to: toDate,
                    background: Colors.blue,
                    isAllDay: false,
                  );
                  await _databaseHelper.insertMeeting(newMeeting);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {

  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}