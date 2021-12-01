import 'package:flutter/material.dart';

import 'blood_data.dart';

class  ResultForm extends StatelessWidget {
  const  ResultForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preliminary New Data Form'),

      ),
      body:  const  ResultBody(title: 'Preliminary New Data Form'),
      //backgroundColor: Colors.blueGrey,
    );
  }
}



// Stateful class for Sherlock Home Page.
class   ResultBody extends StatefulWidget {
  const   ResultBody({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State< ResultBody> createState() => _ResultBodyState();
}

// State class class for Sherlock Home Page.
class _ResultBodyState extends State<  ResultBody> {
  TextEditingController loadFileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    return Scaffold(
      body: Container(
        color: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            // The main axis is the vertical axis for Columns.
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                    controller: loadFileController,
                    onChanged: (v) => loadFileController.text = v,
                    decoration: const InputDecoration(
                      labelText: 'Enter name of your saved data file',
                    )),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: ElevatedButton(
                      child: const Text('Load File'),
                      onPressed: () {
                        print('Pressed me');
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white70,
    );
  }
}


