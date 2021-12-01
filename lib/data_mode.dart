//Page 2 Home
import 'package:flutter/material.dart';

import 'pre_data_form.dart';
import 'new_data_form.dart';
import 'dataset.dart';
import 'stain_parameters.dart';



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
          // The main axis is the vertical axis for Columns.
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
           Image.asset('images/logo.png'),
           Image.asset('images/bloodsplat.png'),
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                
                '',
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'What would you like to do?',
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
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
                          //new datset is clicked
                          //COuld change to morgans and goes to her own identification page
                          //goes to *new_data_ form*, identification page
                          MaterialPageRoute(
                              builder: (context) => const NewDataPage()),
                              //StainParameters(data))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          primary: Colors.green,
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
                          //goes to page 4 pre_data_form
                            builder: (context) => const LoadFileForm()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        primary: Colors.green,
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
