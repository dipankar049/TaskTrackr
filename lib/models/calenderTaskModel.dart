// lib/models/meeting.dart

import 'package:flutter/material.dart';

class Meeting {
  int? id;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  Meeting({
    this.id,
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  // Convert a Meeting into a Map for insertion into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'background': background.value,
      'isAllDay': isAllDay ? 1 : 0,
    };
  }

  // Extract a Meeting from a Map
  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'],
      eventName: map['eventName'],
      from: DateTime.parse(map['from']),
      to: DateTime.parse(map['to']),
      background: Color(map['background']),
      isAllDay: map['isAllDay'] == 1,
    );
  }
}
