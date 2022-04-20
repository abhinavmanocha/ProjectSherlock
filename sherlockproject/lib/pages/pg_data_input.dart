import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sherlock/models/stain_comment.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:fluttertoast/fluttertoast.dart';
import '../models/blood_sample.dart';
import '../models/blood_stains.dart';
import '../services/db_service.dart';
import 'pg_results.dart';

// import 'main.dart';
Color sherlockGrey = const Color(0xFF7C7C7C);
Color sherlockDarkGreen = const Color(0xFF215A47);
Color sherlockBorderGreen = const Color(0xFF028958);
Color sherlockLightGreen = const Color(0xFFE8F3F5);

class BloodDataPage extends StatelessWidget {
  const BloodDataPage({Key? key, required this.sample}) : super(key: key);
  final BloodSample sample;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BloodDataForm(sample: sample),
    );
  }
}

// Stateful class for Sherlock Home Page.
class BloodDataForm extends StatefulWidget {
  const BloodDataForm({Key? key, required this.sample}) : super(key: key);
  final BloodSample sample;

  @override
  State<BloodDataForm> createState() => _BloodDataFormState();
}

// State class class for Sherlock Home Page.
class _BloodDataFormState extends State<BloodDataForm> {
  final List<GlobalKey<FormState>> _formKeys = [];


  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.sample.numStains; i++) {
      _formKeys.add(GlobalKey<FormState>());
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stain Parameters'),
      ),
      body: ListView(
        //shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
              color: Colors.grey,
            ),
            child: const Text(
              'Dataset Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // const Flexible(
          //   child:
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
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
          //),
          _generateForms(),
          const SizedBox(
            height: 55,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: 350,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 55,
                child: TextButton(
                  child: Column(
                    children: const [
                      Icon(Icons.home, color: Colors.teal),
                      Flexible(
                          child: Text('Home',
                              style: TextStyle(color: Colors.teal))),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> routr) => false);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                height: 55,
                child: TextButton(
                  child: Column(
                    children: const [
                      Icon(Icons.save, color: Colors.teal),
                      Flexible(
                          child: Text('save',
                              style: TextStyle(color: Colors.teal))),
                    ],
                  ),
                  onPressed: () => _saveData(context),
                ),
              ),
              SizedBox(
                width: 80,
                height: 60,
                child: TextButton(
                  child: Column(children: const [
                    Icon(Icons.approval, color: Colors.teal),
                    Flexible(
                        child: Text('Process Data',
                            style: TextStyle(color: Colors.teal))),
                  ]),
                  onPressed: () {
                    bool hasErrors = _saveData(context);
                    if (hasErrors) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ResultsPage(sample: widget.sample)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  _showMessage(BuildContext context, String title, {String content = ""}) {
    final alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter some value';
    }
    return null;
  }
  bool _saveData(BuildContext context) {
    bool hasErrors = false;
    for (int i = 0; i < widget.sample.numStains; i++) {
      if (_formKeys[i].currentState!.validate()) {
        _formKeys[i].currentState!.save();
      } else {
        hasErrors = true;
      }
    }

    String msg;
    if (hasErrors) {
      msg = "Data validation failed.";
    } else {
      DBService.saveData(widget.sample);
      msg =
          'Data saved in ${widget.sample.filename}.\nUse this name to reload your data at a later time';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    return hasErrors;
  }

  Widget _generateForms() {
    final children = [
      for (int i = 0; i < widget.sample.numStains; ++i) _formBox(i)
    ];
    return Column(
      children: children,
    );
  }

  Widget _formBox(int index) {
    String stain = "Stain # ${index + 1}";
    return Container(
      width: 340,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: sherlockLightGreen,
          border: Border.all(width: 2.0, color: sherlockBorderGreen)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKeys[index],
          child: Column(
            children: [
              Container(
                width: 270,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.teal)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        stain,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FormField(
                        initialValue: true,
                        builder: (FormFieldState<bool> field) {
                          return SizedBox(
                            width: 50,
                            child: Switch(
                              activeColor: Colors.orange,
                                value: widget.sample.bloodStains[index].include,                                
                                onChanged: (bool val) {
                                  setState(() {
                                    widget.sample.bloodStains[index].include =
                                        val;
                                  });
                                }),
                          );
                        }),
                    const Text("Include"),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 135,
                    height: 40,
                    child: TextFormField(
                      onSaved: (value) {widget.sample.bloodStains[index].alpha = double.parse(value!); },
                      initialValue:
                          widget.sample.bloodStains[index].alpha.toString(),
                      decoration: const InputDecoration(labelText: "α Angle"),
                      keyboardType: TextInputType.number,
                      validator: _validateInput,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 135,
                    height: 40,
                    child: TextFormField(
                      onSaved: (value) {widget.sample.bloodStains[index].gamma = double.parse(value!); },
                      initialValue:
                          widget.sample.bloodStains[index].gamma.toString(),
                      decoration: const InputDecoration(labelText: "γ Angle"),
                      keyboardType: TextInputType.number,
                      validator: _validateInput,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 135,
                    height: 40,
                    child: TextFormField(
                      onSaved: (value) {widget.sample.bloodStains[index].y = double.parse(value!); },
                      initialValue:
                          widget.sample.bloodStains[index].y.toString(),
                      decoration: const InputDecoration(labelText: "Y Coord."),
                      keyboardType: TextInputType.number,
                      validator: _validateInput,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 135,
                    height: 40,
                    child: TextFormField(
                      onSaved: (value) {widget.sample.bloodStains[index].z = double.parse(value!); },
                      initialValue:
                          widget.sample.bloodStains[index].z.toString(),
                      decoration: const InputDecoration(labelText: "Z Coord."),
                      keyboardType: TextInputType.number,
                      validator: _validateInput,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 270,
                    child: DropdownButtonFormField<StainComment>(
                      value: widget.sample.bloodStains[index].comment,
                      hint: const Text("Comment"),
                      items: const [
                        DropdownMenuItem<StainComment>(
                          value: StainComment.none,
                          child: Text(""),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badAlphaValue,
                          child: Text("Bad alpha value"),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badGammaValue,
                          child: Text("Bad gamma value"),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badYOrZCoord,
                          child: Text("Bad Y or Z coordinate"),
                        )
                      ],
                      onSaved: (value) {widget.sample.bloodStains[index].comment = value as StainComment; },
                      onChanged: (value) {
                        setState(() {
                          widget.sample.bloodStains[index].comment =
                              value as StainComment;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ); //ListViewBuilder
  }

  _getDropDownValue() {
    var comments = StainComment.values;
  }
}
