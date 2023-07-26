import 'package:flutter/material.dart';

// Widget to show the Reminders component in the application.
class ReminderList extends StatelessWidget {
  final String userName;
  const ReminderList({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0.0),
      children: [
        ReminderCard(
          title: '${userName}reminder placeholder',
          time: '10:00 AM',
        ),
      ],
    );
  }
}

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;

  const ReminderCard({
    Key? key,
    required this.title,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
