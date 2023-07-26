import 'package:flutter/material.dart';

// Main component of MedicineReminder widget
class MedicineReminderList extends StatelessWidget {
  final String userName;
  const MedicineReminderList({Key? key, required this.userName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0.0),
      children: [
        MedicineReminderCard(
          name: '${userName}medicine reminder placeholder',
          dosage: '1 tablet',
          time: '10:00 AM',
        ),
      ],
    );
  }
}

class MedicineReminderCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;

  const MedicineReminderCard({
    Key? key,
    required this.name,
    required this.dosage,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dosage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
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
