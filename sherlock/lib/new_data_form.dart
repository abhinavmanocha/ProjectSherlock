//Page 3 identification (When new datset is clicked)
import 'package:flutter/material.dart';
import 'dataset.dart';
import 'stain_parameters.dart';

class NewDataPage extends StatelessWidget {
  const NewDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Dataset",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
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
  final TextEditingController _numStainsController = TextEditingController();

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      // final stain = {
      //   'teamName': _teamNameController.text,
      //   'patternId': _patternIdController.text,
      //   'numStains': _numStainsController.text,
      // };

      final data = Dataset(_teamNameController.text, _patternIdController.text,
          int.parse(_numStainsController.text));

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => StainParameters(data)),
      );
    }
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      // child:
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 14),
                child: Text(
                  'Your team name and pattern ID will be used to automatically '
                  'save your data for you when you run the analysis.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: TextFormField(
                  focusNode: _teamNameFocusNode,
                  controller: _teamNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your team name';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your pattern ID';
                    }
                    return null;
                  },
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
                  controller: _numStainsController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        int.tryParse(value) == null ||
                        int.parse(value) > 20 ||
                        int.parse(value) < 1) {
                      return 'Please enter a number between 1-20';
                    }
                    return null;
                  },
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

                    //button to stain parameters
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.green,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        // ****Change to morgan's stain parameters****
                        onPressed: _submitForm,
                        //onPressed: () {
                        // Navigator.push(
                        // context,
                        //MaterialPageRoute(
                        // builder: (context) => const *inset new file*()),
                        //note add some ) until it works

                        //don't change
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
