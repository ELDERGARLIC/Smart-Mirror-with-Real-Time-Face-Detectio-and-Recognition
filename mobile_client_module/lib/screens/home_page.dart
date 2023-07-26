// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:realtime_face_detection/main.dart';
import 'package:realtime_face_detection/util/menu_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // padding constants
  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // app bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // menu icon
                  Image.asset(
                    'lib/icons/menu.png',
                    height: 30,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // welcome home
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.3,
                  ),
                  children: [
                    MenuButton(
                      smartDeviceName: "Reminders",
                      iconPath: "lib/icons/reminder.png",
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController reminder =
                                  TextEditingController();
                              TextEditingController user =
                                  TextEditingController();
                              return AlertDialog(
                                title: Text(
                                  "Add Reminder",
                                  textAlign: TextAlign.center,
                                ),
                                alignment: Alignment.center,
                                content: SizedBox(
                                  height: 340,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: user,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Enter Username",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: reminder,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Enter Reminder",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final firestore =
                                              FirebaseFirestore.instance;
                                          await firestore
                                              .collection('reminders')
                                              .add({user.text: reminder.text});
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          minimumSize: const Size(200, 40),
                                        ),
                                        child: const Text("Save"),
                                      )
                                    ],
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              );
                            });
                      },
                    ),
                    MenuButton(
                      smartDeviceName: "Medicine Reminders",
                      iconPath: "lib/icons/medicine.png",
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController medicineReminder =
                                  TextEditingController();
                              TextEditingController user =
                                  TextEditingController();
                              return AlertDialog(
                                title: Text(
                                  "Add Reminder",
                                  textAlign: TextAlign.center,
                                ),
                                alignment: Alignment.center,
                                content: SizedBox(
                                  height: 340,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: user,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Enter Username",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: medicineReminder,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Enter Medicine Reminder",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final firestore =
                                              FirebaseFirestore.instance;
                                          await firestore
                                              .collection('medicine-reminders')
                                              .add({
                                            user.text: medicineReminder.text
                                          });
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          minimumSize: const Size(200, 40),
                                        ),
                                        child: const Text("Save"),
                                      )
                                    ],
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              );
                            });
                      },
                    ),
                    MenuButton(
                      smartDeviceName: "Add User",
                      iconPath: "lib/icons/user.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUserPage(),
                          ),
                        );
                      },
                    ),
                    MenuButton(
                      smartDeviceName: "Settings",
                      iconPath: "lib/icons/settings.png",
                      onTap: () {},
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
