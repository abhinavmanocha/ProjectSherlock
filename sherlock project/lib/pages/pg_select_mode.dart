import 'package:flutter/material.dart';

import 'pg_file_prompt.dart';
import 'pg_new_data_prompt.dart';

class DataMode extends StatelessWidget {
  const DataMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DataModePage(),
    );
  }
}

// Stateful class for Sherlock Home Page.
class DataModePage extends StatefulWidget {
  const DataModePage({Key? key}) : super(key: key);

  @override
  State<DataModePage> createState() => _DataModePageState();
}

// State class class for Sherlock Home Page.
class _DataModePageState extends State<DataModePage> {
  // void _saveCounter() {
  //   setState(() {
  //     _numStains++;
  //   });
  // }

  // void _showResultsPage() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute<void>(
  //       builder: (context) {
  //         return Scaffold(
  //           appBar: AppBar(
  //             title: const Text('Analysis Results'),
  //           ),
  //           body: const Center(
  //             child: Text('Analysis Results'),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                'images/sherlock_logo_white-removebg-preview.png',
                width: 300.0,
                height: 300.0,
                fit: BoxFit.contain,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'What would you like to do?',
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      child: const Text('New Dataset'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewDataPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        primary: Colors.indigoAccent,
                        onPrimary: Colors.white,
                        minimumSize: const Size(200.0, 20.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Pre-existing Datasets'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoadFileForm()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      primary: Colors.indigo,
                      onPrimary: Colors.white,
                      minimumSize: const Size(200.0, 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
