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
        title: const Text('Calendar'),
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _databaseHelper.getMeetings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SfCalendar(
              view: CalendarView.month,
              onTap: calendarTapped,
              dataSource: MeetingDataSource([]),
              initialSelectedDate: DateTime.now(),
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
              ),
            );
          } else {
            return SfCalendar(
              view: CalendarView.month,
              onTap: calendarTapped,
              dataSource: MeetingDataSource(snapshot.data!),
              initialSelectedDate: DateTime.now(),
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
              ),
            );
          }
        },
      ),
    );
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      _showAddEventDialog(details.date!);
    }
  }

  void _showAddEventDialog(DateTime selectedDate) {
    final _eventNameController = TextEditingController();
    DateTime _fromDate = selectedDate;
    DateTime _toDate = selectedDate.add(Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text('From: ${_fromDate.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fromDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _fromDate = picked);
                },
              ),
              ListTile(
                title: Text('To: ${_toDate.toString()}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _toDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _toDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_eventNameController.text.isNotEmpty) {
                  final newMeeting = Meeting(
                    eventName: _eventNameController.text,
                    from: _fromDate,
                    to: _toDate,
                    background: Colors.blue,
                    isAllDay: false,
                  );
                  await _databaseHelper.insertMeeting(newMeeting);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
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