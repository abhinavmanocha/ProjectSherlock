import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

@immutable
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sherlock',
        home: Scaffold(
          body: Container(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
              child: Column(
                children: [
// Trent Forensics logo image
                  Image.asset(
                    'images/forensics_logo.jpg',
                    width: 435,
                    height: 85,
                    fit: BoxFit.fitWidth,
                  ),
// Sherlock title and version number
                  Text(
                    'Sherlock Ver: 0.1.0',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ], // children
              )),
        ));
  }
}
