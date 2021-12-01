//page 4 pre-existing dataset
import 'package:flutter/material.dart';

import 'stain.dart';
import 'blood_data.dart';

//stain para
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
  final FocusNode _chooseFileFocusNode = FocusNode();
  final TextEditingController _chooseFileController = TextEditingController();

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      // final stain = {
      //   'teamName': _teamNameController.text,
      //   'patternId': _patternIdController.text,
      //   'numStains': _chooseFileController.text,
      // };

      final stainInfo = Stain(_chooseFileController.text, '', '');
      
      // If the form passes validation, display a Snackbar.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Form submitted')));
      //_formKey.currentState.save();
      //_formKey.currentState.reset();
      //_nextFocus(_nameFocusNode);

            Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => BloodDataPage(stainInfo: stainInfo)),
      );
    }
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
       
        child: Form(
          
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset('images/bloodsplat.png'),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Pre-exisiting Datasets:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text(
                'If your data is already in a file, type in the filename '
                'and press LOAD.',
              ),),
               Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                focusNode: _chooseFileFocusNode,
                controller: _chooseFileController,
                keyboardType: const TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some value';
                  }
                  return null;
                },
                onFieldSubmitted: (String value) {
                  _submitForm();
                },
                decoration: const InputDecoration(
                  hintText: 'Choose file',
                  labelText: 'Load',
                ),
              ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Load File'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.all(20),
                          minimumSize: Size(200, 20),
                        ),
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
