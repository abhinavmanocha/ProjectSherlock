import 'package:flutter/material.dart';

import 'pages/pg_select_mode.dart';

void main() {
  runApp(const SherlockApp());
}

class SherlockApp extends StatelessWidget {
  const SherlockApp({Key? key}) : super(key: key);

  // Root of the App Widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: const Color(0xff1E5646),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Sherlock',
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'NOTE: Sherlock was designed for student training purposes '
                    'only, we do not guarantee that the results are 100% accurate. '
                    'Trent University assumes no responsibility or liability should '
                    'you attempt to use the software in a criminal or civil court case.',
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        child: const Text('Open'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DataMode()),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: 16.0),
                //   child: Text(
                //     'No. of Stains: $_numStains',
                //     style: Theme.of(context).textTheme.headline4,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



  