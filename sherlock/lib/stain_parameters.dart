import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dataset.dart';
import 'results.dart';
import 'files.dart';

Color sherlockGrey = const Color(0xFF7C7C7C);
Color sherlockDarkGreen = const Color(0xFF215A47);
Color sherlockBorderGreen = const Color(0xFF028958);
Color sherlockLightGreen = const Color(0xFFE8F3F5);

// dataset object where all of the stain parameters will be stored
Dataset data = Dataset.empty();
// global form key uniquely identifies the Form widget and allows validation
final _formKey = GlobalKey<FormState>();

class StainParameters extends StatelessWidget {
  // constructor
  StainParameters(Dataset dataset, {Key? key}) : super(key: key) {
    data = dataset;
  }

  @override
  Widget build(BuildContext context) {
    String infoText =
        "Please enter/edit your blood spatter data in the following table."
                " Your team name and pattern ID will be used to automatically save"
                " your data for you when you run the analysis."
                "\n\nTeam Name: " +
            data.teamName +
            "\nPattern ID: " +
            data.patternID;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Stain Parameters",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigate back to previous screen when tapped.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Dataset Information",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(300, 60),
                              primary: sherlockGrey,
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            infoText,
                            style: TextStyle(
                              fontSize: 16,
                              color: sherlockGrey,
                            ),
                          ),
                        ),
                        const StainParametersForm(),
                      ]),
                    )))),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                if (await StainParametersFormState.processForm()) {
                  // if form submission was successful, go to results page
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Results(data)),
                  );
                }
              },
              child: const Text(
                "Process Data",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 60),
                  primary: sherlockDarkGreen,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ));
  }
} // --- End Stain Parameters Class

// Define a custom Form widget.
class StainParametersForm extends StatefulWidget {
  // constructor
  const StainParametersForm({Key? key}) : super(key: key);

  @override
  StainParametersFormState createState() {
    return StainParametersFormState();
  }
}

// This class holds data related to the form.
class StainParametersFormState extends State<StainParametersForm> {
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
// --- All the form fields go here --------------------------------------------
          for (int i = 0; i < data.numStains; ++i) formBox(i + 1),
        ],
      ),
    );
  } // --- End build function

  // This function creates the form fields for each stain
  Widget formBox(int stainID) {
    String stain = "Stain Number " + stainID.toString();
    String? alphaAngle = (data.stains[stainID - 1].alphaAngle == null)
        ? null
        : data.stains[stainID - 1].alphaAngle.toString();
    String? gammaAngle = (data.stains[stainID - 1].gammaAngle == null)
        ? null
        : data.stains[stainID - 1].gammaAngle.toString();
    String? yCoord = (data.stains[stainID - 1].yCoord == null)
        ? null
        : data.stains[stainID - 1].yCoord.toString();
    String? zCoord = (data.stains[stainID - 1].zCoord == null)
        ? null
        : data.stains[stainID - 1].zCoord.toString();
    return Container(
        width: 340,
        height: 180,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: sherlockLightGreen,
            border: Border.all(width: 2.0, color: sherlockBorderGreen)),
        child: Column(
          children: [
            Text(
              stain,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                SizedBox(
                    // --- α Angle --------------------------------------------
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(hintText: "α Angle"),
                      keyboardType: TextInputType.number,
                      initialValue: alphaAngle,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return "Enter a number";
                        }
                        setState(() {
                          data.stains[stainID - 1].alphaAngle =
                              double.parse(value);
                        });
                        return null;
                      },
                    )),
                const SizedBox(
                  // whitespace
                  width: 10,
                ),
                SizedBox(
                    // --- γ Angle --------------------------------------------
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(hintText: "γ Angle"),
                      keyboardType: TextInputType.number,
                      initialValue: gammaAngle,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return "Enter a number";
                        }
                        setState(() {
                          data.stains[stainID - 1].gammaAngle =
                              double.parse(value);
                        });
                        return null;
                      },
                    )),
              ],
            ),
            Row(
              children: [
                SizedBox(
                    // --- Y Coordinate ---------------------------------------
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(hintText: "Y Coord."),
                      keyboardType: TextInputType.number,
                      initialValue: yCoord,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return "Enter a number";
                        }
                        setState(() {
                          data.stains[stainID - 1].yCoord = double.parse(value);
                        });
                        return null;
                      },
                    )),
                const SizedBox(
                  // whitespace
                  width: 10,
                ),
                SizedBox(
                    // --- Z Coordinate ---------------------------------------
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(hintText: "Z Coord."),
                      keyboardType: TextInputType.number,
                      initialValue: zCoord,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return "Enter a number";
                        }
                        setState(() {
                          data.stains[stainID - 1].zCoord = double.parse(value);
                        });
                        return null;
                      },
                    )),
              ],
            ),
            Row(
              children: [
                // --- Include ------------------------------------------------
                const Text("Include"),
                FormField(
                    initialValue: true,
                    builder: (FormFieldState<bool> field) {
                      return SizedBox(
                          width: 60,
                          child: Switch(
                              value: data.stains[stainID - 1].include,
                              onChanged: (bool value) {
                                setState(() {
                                  data.stains[stainID - 1].include = value;
                                });
                              }));
                    }),
                SizedBox(
                    // --- Comment --------------------------------------------
                    width: 200,
                    child: DropdownButtonFormField<stain_comment>(
                      hint: const Text("Comment"),
                      value: data.stains[stainID - 1].comment,
                      items: const [
                        DropdownMenuItem<stain_comment>(
                          value: stain_comment.none,
                          child: Text(""),
                        ),
                        DropdownMenuItem<stain_comment>(
                          value: stain_comment.badAlphaValue,
                          child: Text("Bad alpha value"),
                        ),
                        DropdownMenuItem<stain_comment>(
                          value: stain_comment.badGammaValue,
                          child: Text("Bad gamma value"),
                        ),
                        DropdownMenuItem<stain_comment>(
                          value: stain_comment.badYOrZCoord,
                          child: Text("Bad Y or Z coordinate"),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          data.stains[stainID - 1].comment = value;
                        });
                      },
                    ))
              ],
            ),
          ],
        ));
  } // --- End formBox function

  static Future<bool> processForm() async {
    if (_formKey.currentState!.validate()) {
      // if form is valid, save dataset to csv file, then go to next page
      // first create the text string that will be written to the file
      String filename = data.teamName + "_" + data.patternID + ".csv";
      String fileText = "Number of data points:" +
          data.numStains.toString() +
          ":\n" +
          data.teamName +
          ":" +
          data.patternID +
          ":\n";
      // data for each stain
      for (int i = 0; i < data.numStains; ++i) {
        fileText += data.stains[i].alphaAngle.toString() +
            ":" +
            data.stains[i].gammaAngle.toString() +
            ":" +
            data.stains[i].yCoord.toString() +
            ":" +
            data.stains[i].zCoord.toString() +
            ":";
        if (data.stains[i].include) {
          fileText += "Y:";
        } else {
          fileText += "N:";
        }
        fileText += data.stains[i].comment.toString() + ":\n";
      }

      // write the actual file
      FileManager.writeFile(filename, fileText);
      return true;
    }
    return false;
  } // --- End processForm function
} // --- End StainParametersFormState
