import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String title;

  const ReminderCard({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white38,
            width: 0.5,
          ),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
