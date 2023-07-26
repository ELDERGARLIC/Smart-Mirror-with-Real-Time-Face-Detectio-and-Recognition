import 'package:flutter/material.dart';
import 'package:realtime_face_detection/models/mail.dart';

// MailList widget
class MailList extends StatelessWidget {
  final List<Mail> mailItems = [
    const Mail(
      sender: 'John Doe',
      title: 'Important Meeting Reminder',
      body: 'Dear team, This is a reminder for our important meeting...',
    ),
    const Mail(
      sender: 'Jane Smith',
      title: 'Upcoming Event Announcement',
      body: 'Hello everyone, We have an exciting event coming up...',
    ),
  ];

  MailList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(5.0),
      itemCount: mailItems.length,
      itemBuilder: (context, index) {
        final mailItem = mailItems[index];
        return MailCard(
          sender: mailItem.sender,
          title: mailItem.title,
          body: mailItem.body,
        );
      },
    );
  }
}

class MailCard extends StatelessWidget {
  final String sender;
  final String title;
  final String body;

  const MailCard({
    Key? key,
    required this.sender,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: ListTile(
        title: Text(
          sender,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
