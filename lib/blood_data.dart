import 'package:flutter/material.dart';
import 'results.dart';

import 'stain.dart';
import 'main.dart';

// import 'main.dart';

class BloodDataPage extends StatelessWidget {
  const BloodDataPage({Key? key, required this.stainInfo}) : super(key: key);
  final Stain stainInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stain Parameters'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,

        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.list),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const SherlockApp()),
        //       );
        //     },
        //     tooltip: 'Home',
        //   ),
        // ],
      ),
      body: BloodDataForm(stainInfo: stainInfo),
    );
  }
}

// Stateful class for Sherlock Home Page.
class BloodDataForm extends StatefulWidget {
  const BloodDataForm({Key? key, required this.stainInfo}) : super(key: key);
  final Stain stainInfo;

  @override
  State<BloodDataForm> createState() => _BloodDataFormState();
}

// State class class for Sherlock Home Page.
class _BloodDataFormState extends State<BloodDataForm> {
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

      final stainInfo = Stain(_teamNameController.text,
          _patternIdController.text, _numStainsController.text);

      // If the form passes validation, display a Snackbar.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Form submitted')));
      //_formKey.currentState.save();
      //_formKey.currentState.reset();
      //_nextFocus(_nameFocusNode);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SherlockApp()),
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
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.grey,
              child: const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 14),
                child: Text(
                  'Dataset Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Please enter/edit your blood splatter data in the '
                'following table. Your team name and pattern ID will '
                'be used to automatically save your data for you when '
                'you run the analysis.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              color: Colors.grey,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(widget.stainInfo.toString()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text('Home'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SherlockApp()),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text('Process Data'),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const ResultForm()),
                    // );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
