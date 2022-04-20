import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:fluttertoast/fluttertoast.dart';
import '../models/blood_sample.dart';
import '../models/blood_stains.dart';
import 'pg_results.dart';
import '../services/db_service.dart';

// import 'main.dart';

class BloodDataPage_BAK extends StatelessWidget {
  const BloodDataPage_BAK({Key? key, required this.sample}) : super(key: key);
  final BloodSample sample;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BloodDataForm_BAK(sample: sample),
    );
  }
}

// Stateful class for Sherlock Home Page.
class BloodDataForm_BAK extends StatefulWidget {
  const BloodDataForm_BAK({Key? key, required this.sample}) : super(key: key);
  final BloodSample sample;

  @override
  State<BloodDataForm_BAK> createState() => _BloodDataFormState_BAK();
}

// State class class for Sherlock Home Page.
class _BloodDataFormState_BAK extends State<BloodDataForm_BAK> {
  // final _formKey = GlobalKey<FormState>();

  ////////////////////////////////////////////////////////////////////
  // Map<String, _StrainEditingController> _controllerMap = Map();  //
  ////////////////////////////////////////////////////////////////////
  ///
  final List<_StrainEditingController> _strainControllers = [];
  final List<TextField> _alphaFields = [];
  final List<TextField> _gammaFields = [];
  final List<TextField> _yFields = [];
  final List<TextField> _zFields = [];
  final List<Widget> _includeBox = [];
  final List<TextField> _commentFields = [];

  ///
  ////////////////////////////////////////////////////////////////////////
  // @override                                                          //
  // void dispose() {                                                   //
  //   _controllerMap.forEach((_, controller) => controller.dispose()); //
  //   super.dispose();                                                 //
  // }                                                                  //
  ////////////////////////////////////////////////////////////////////////
  ///

  @override
  void dispose() {
    for (final controller in _strainControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<BloodSample> _retrieveData() async {
    if (widget.sample.isNew) {
      return widget.sample;
    } else {
      Future<BloodSample> data = DBService.readData(widget.sample);
      return data;
    }
    // return Future.value(auxStain);
  }



  Widget _genCheckbox(int i, bool val, String labelText) {
    return Row (
      children: [
      const Text("Include"),
      Checkbox(
        value: val,
        onChanged: (value) {
          setState(() {
            _strainControllers[i].include = value!;
          });
        }),
    ]);
  }

  TextField _genTextField(
      TextEditingController controller, String labelText, bool isNum) {
    return TextField(
      controller: controller,
      keyboardType: isNum
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
    );
  }

  _buildTextField(BloodSample data) {
    final stainCount = data.stainCount;

    if (stainCount != null) {
      for (int i = 0; i < stainCount; i++) {
        final controller = _StrainEditingController(i, data.bloodStains[i]);
        final alphaField =
            _genTextField(controller.alpha, '\u03B1 Angle', true);
        final gammaField =
            _genTextField(controller.gamma, '\u03B3 Angle', true);
        final yField = _genTextField(controller.y, 'y Coord', true);
        final zField = _genTextField(controller.z, 'z Coord.', true);
        final includeBox = _genCheckbox(i, controller.include, "Include");
        final commentField =
            _genTextField(controller.comment, 'Comment', false);

        // setState(() {
        _strainControllers.add(controller);
        _alphaFields.add(alphaField);
        _gammaFields.add(gammaField);
        _yFields.add(yField);
        _zFields.add(zField);
        _includeBox.add(includeBox);
        _commentFields.add(commentField);
        // });
      }
      setState(() {});
    }
  }



  Widget _buildDataListView() {
    _buildTextField(widget.sample);

    return ListView.builder(
      shrinkWrap: true,
      //physics: const ClampingScrollPhysics(),
      itemCount: widget.sample.numStains,
      padding: const EdgeInsets.all(8),
      itemBuilder: (BuildContext context, int index) {
        return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Stain Number ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(children: [
                Expanded(child: _alphaFields[index]),
                Expanded(child: _gammaFields[index]),
              ]),
              Row(children: [
                Expanded(child: _yFields[index]),
                Expanded(child: _zFields[index]),
              ]),
              Row(children: [
                Expanded(child: _includeBox[index]),
                Expanded(child: _commentFields[index]),
              ]),
            ]));
      },
    );
  }

  

  showMessage(BuildContext context, String text, String s) async {
    final alert = AlertDialog(
      title: Text(s),
      content: Text(text.trim()),
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

  _saveData(BuildContext context) {
    String msg;
    if (_strainControllers.isNotEmpty) {
      for (int index = 0; index < _strainControllers.length; index++) {
        widget.sample.bloodStains[index].alpha =
            double.parse(_strainControllers[index].alpha.text);
        widget.sample.bloodStains[index].gamma =
            double.parse(_strainControllers[index].gamma.text);
        widget.sample.bloodStains[index].y =
            double.parse(_strainControllers[index].y.text);
        widget.sample.bloodStains[index].z =
            double.parse(_strainControllers[index].z.text);
        widget.sample.bloodStains[index].include =
            _strainControllers[index].include;
        // widget.sample.bloodStains[index].comment =
        //     _strainControllers[index].comment.text;
      }

      if (widget.sample.errors.isEmpty) {
        msg =
            'Data saved in ${widget.sample.filename}.\nUse this name to reload your data at a later time';
      } else {
        msg = widget.sample.errors;
      }
    } else {
      msg = "No blood data yet";
    }

    setState(() {});

    DBService.saveData(widget.sample);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const SliverAppBar(
              pinned: true,
              title: Text('Stain Parameters'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shadowColor: Colors.white,
              elevation: 0.0,
              centerTitle: true,
            ),
          ];
        },
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              //color: Colors.grey[850],
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.teal,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                color: Colors.grey,
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Text(
                  'Dataset Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Flexible(
              child: Padding(
                padding: EdgeInsets.all(20),
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
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: _buildDataListView(),
            ),
            Flexible(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: Column(
                        children: const [
                          Icon(Icons.home),
                          Flexible(child: Text('Home')),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> routr) => false);
                      },
                    ),
                    TextButton(
                      child: Column(
                        children: const [
                          Icon(Icons.save),
                          Flexible(child: Text('save')),
                        ],
                      ),
                      onPressed: () => _saveData(context),
                    ),
                    TextButton(
                      child: Column(children: const [
                        Icon(Icons.approval),
                        Flexible(child: Text('Process Data')),
                      ]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResultsPage(sample: widget.sample)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrainEditingController {
  int id;
  TextEditingController alpha = TextEditingController();
  TextEditingController gamma = TextEditingController();
  TextEditingController y = TextEditingController();
  TextEditingController z = TextEditingController();
  TextEditingController comment = TextEditingController();
  bool include = true;

  _StrainEditingController(this.id, BloodStain stain) {
    alpha.text = stain.alpha.toString();
    gamma.text = stain.gamma.toString();
    y.text = stain.y.toString();
    z.text = stain.z.toString();
    include = stain.include;
  }


  void dispose() {
    alpha.dispose();
    gamma.dispose();
    y.dispose();
    z.dispose();
    comment.dispose();
  }
}
