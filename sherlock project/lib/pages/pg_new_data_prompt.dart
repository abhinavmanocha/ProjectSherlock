import 'package:flutter/material.dart';

import 'pg_data_input.dart';
import '../models/blood_sample.dart';

class NewDataPage extends StatelessWidget {
  const NewDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white,
        elevation: 0.0,
      ),
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      // child:
      body: const NewDataForm(),
    );
  }
}

// Stateful class for Sherlock Home Page.
class NewDataForm extends StatefulWidget {
  const NewDataForm({Key? key}) : super(key: key);

  @override
  State<NewDataForm> createState() => _NewDataFormState();
}

// State class class for Sherlock Home Page.
class _NewDataFormState extends State<NewDataForm> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _teamNameFocusNode = FocusNode();
  final FocusNode _patternIdFocusNode = FocusNode();
  final FocusNode _numStainsFocusNode = FocusNode();

  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _patternIdController = TextEditingController();
  final TextEditingController _stainCountController = TextEditingController();

  _submitForm() {
    //Retrieve user input, and process if they are valid.
    if (_formKey.currentState!.validate()) {
      String teamName = _teamNameController.text.trim();
      String patternId = _patternIdController.text.trim();
      int? stainCount = int.tryParse(_stainCountController.text.trim());

      String filename = teamName + '_' + patternId + '.csv';

      final sample = BloodSample(
          isNew: true,
          teamName: teamName,
          patternId: patternId,
          stainCount: stainCount,
          filename: filename);

      sample.teamInfo = true;
      sample.initBloodStains();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BloodDataPage(sample: sample)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct invalid values')));
    }
  }

  String? _validateNumInput(String? value) {
    String? msg = _validateInput(value);
    if (msg != null) {
      return msg;
    }

    final number = int.tryParse(value!.trim());
    if (number == null || number < 1 || number > 20) {
      return 'Please enter a numeric value between 0 and 20';
    }

    return null;
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter some value';
    }
    if (value.contains(':')) {
      return 'The character \':\' is not allowed';
    }
    if (value.contains(' ')) {
      return 'The space character is not allowed';
    }
    return null;
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 14),
                child: Text(
                  'Dataset Identification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'Your team name and pattern ID will be used to automatically '
                'save your data for you when you run the analysis.',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: TextFormField(
                  focusNode: _teamNameFocusNode,
                  controller: _teamNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validateInput,
                  onFieldSubmitted: (String value) {
                    _nextFocus(_patternIdFocusNode);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter name of the team',
                    labelText: 'Team Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  focusNode: _patternIdFocusNode,
                  controller: _patternIdController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validateInput,
                  onFieldSubmitted: (String value) {
                    _nextFocus(_numStainsFocusNode);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter pattern ID',
                    labelText: 'Pattern ID',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  focusNode: _numStainsFocusNode,
                  controller: _stainCountController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.done,
                  validator: _validateNumInput,
                  onFieldSubmitted: (String value) {
                    _submitForm();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter the number of stains',
                    labelText: 'Number of Stains',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                    ),
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Color.fromARGB(255, 0, 77, 64),
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
