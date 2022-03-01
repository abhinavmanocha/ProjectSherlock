//page 4 pre-existing dataset
import 'package:flutter/material.dart';
import 'stain_parameters.dart';
import 'dataset.dart';
import 'files.dart';

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
  String filename = ""; // name of file to load

  _submitForm() async {
    if (_formKey.currentState!.validate() || filename == "sample") {
      // open file and save contents to list, each item is one row,
      // each sub-item is one column in that row
      List<List<String>> fileContents = await FileManager.readFile(filename);

      // make sure the file exists and has content
      if (fileContents.isNotEmpty) {
        // create dataset with team name, pattern ID, and number of stains
        final data = Dataset(fileContents[1][0], fileContents[1][1],
            int.parse(fileContents[0][1]));
        // add data for each stain
        for (int i = 2;
            i < fileContents.length && i < data.numStains + 2;
            ++i) {
          data.stains[i - 2].alphaAngle = double.parse(fileContents[i][0]);
          data.stains[i - 2].gammaAngle = double.parse(fileContents[i][1]);
          data.stains[i - 2].yCoord = double.parse(fileContents[i][2]);
          data.stains[i - 2].zCoord = double.parse(fileContents[i][3]);
          // include is true by default, so don't need else here
          if (fileContents[i][4] == "N") {
            data.stains[i - 2].include = false;
          }
          // comment is none by default so no need to check for that
          if (fileContents[i][5] == "stain_comment.badAlphaValue") {
            data.stains[i - 2].comment = stain_comment.badAlphaValue;
          } else if (fileContents[i][5] == "stain_comment.badGammaValue") {
            data.stains[i - 2].comment = stain_comment.badGammaValue;
          } else if (fileContents[i][5] == "stain_comment.badYOrZCoord") {
            data.stains[i - 2].comment = stain_comment.badYOrZCoord;
          }
        }
        // navigate to stain parameters page, passing the loaded data
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => StainParameters(data)),
        );
      } else {
        // if the file does not exist, display a Snackbar.
        String error = "ERROR: File " + filename + " not found";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              Image.asset('images/sherlock_logo_white.png'),
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
                  'and press LOAD.\n\nExample: teamname_patternID.csv',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  focusNode: _chooseFileFocusNode,
                  controller: _chooseFileController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a filename';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    filename = value;
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
                          padding: const EdgeInsets.all(20),
                          minimumSize: const Size(200, 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          filename = "sample";
                          _submitForm();
                        },
                        child: const Text('Load Sample Data'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.teal,
                          padding: const EdgeInsets.all(20),
                          minimumSize: const Size(200, 20),
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
