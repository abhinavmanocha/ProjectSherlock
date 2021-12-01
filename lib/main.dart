//Page 1 Splash Screen
import 'package:flutter/material.dart';
import 'stain_parameters.dart';
import 'data_mode.dart';

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
                Image.asset('images/forensiclogo.png'),
                Image.asset('images/greensplat.png'),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '',
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        child: const Text('Open',

                        softWrap: true,
                        style: TextStyle(
                       color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                        ),
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

// Any time you're pushing a new route and expect that route
// to return something back to you,
// you need to use an async function.
// In this case, the function will create a form page
// which the user can fill out and submit.
// On submission, the information in that form page
// will be passed back to this function.

  // @override
  // Widget build(BuildContext context) {
  //   // This method is rerun every time setState is called.
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.title),
  //       // actions: [
  //       //   IconButton(
  //       //     icon: const Icon(Icons.list),
  //       //     onPressed: _showResultsPage,
  //       //     tooltip: 'view Results',
  //       //   ),
  //       // ],
  //       // actions: [
  //       //   IconButton(
  //       //     icon: const Icon(Icons.list),
  //       //     onPressed: () {
  //       //       Navigator.push(
  //       //         context,
  //       //         MaterialPageRoute(
  //       //             builder: (context) => const BloodSampleForm()),
  //       //       );
  //       //     },
  //       //     tooltip: 'view Results',
  //       //   ),
  //       // ],
  //     ),
  //     body: 
  //     //backgroundColor: Colors.white70,
  //     // floatingActionButton: FloatingActionButton(
  //     //   onPressed: _saveCounter,
  //     //   tooltip: 'Increment',
  //     //   child: const Icon(Icons.add),
  //     // ), // This trailing comma makes auto-formatting nicer for build methods.
  //   );
  // }
