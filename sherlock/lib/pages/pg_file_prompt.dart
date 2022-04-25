import 'package:flutter/material.dart';

import 'pg_data_input.dart';
import '../models/blood_sample.dart';
import '../services/db_service.dart';

class LoadFileForm extends StatelessWidget {
  const LoadFileForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: const LoadFileBodyForm(title: 'Preliminary New Data Form'),
      //backgroundColor: Colors.blueGrey,
    );
  }
}

// Stateful class for Sherlock Home Page.
class LoadFileBodyForm extends StatefulWidget {
  const LoadFileBodyForm({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoadFileBodyForm> createState() => _LoadFileBodyFormState();
}

// State class class for Sherlock Home Page.
class _LoadFileBodyFormState extends State<LoadFileBodyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fileController = TextEditingController();

  _submitForm() async {        
    if (_formKey.currentState!.validate()) {
      String filename = _fileController.text.trim();
      BloodSample sample = BloodSample(isNew: false, filename: filename);
      //Read file.
      sample = await DBService.readData(sample);

      String errors = sample.errors;

      if (sample.numStains == 0) {
        errors += "File has no data";
      }

      // Display a Snackbar if there are errors.
      if (errors.isEmpty){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: SingleChildScrollView(child: Text(errors))));
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BloodDataPage(sample:sample)),
      );
    }
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter some value';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Pre-existing Datasets:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                'If your data is already in a file, type in the filename '
                'and press LOAD.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: _fileController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: _validateInput,
                onFieldSubmitted: (String value) {
                  _submitForm();
                },
                decoration: const InputDecoration(
                  hintText: 'Choose file',
                  labelText: 'Load',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Load File'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  padding: const EdgeInsets.all(20),
                  minimumSize: const Size(200, 20),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
