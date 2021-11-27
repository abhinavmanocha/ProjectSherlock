import 'package:flutter/material.dart';

Color sherlockGrey = const Color(0xFF7C7C7C);
Color sherlockDarkGreen = const Color(0xFF215A47);
Color sherlockBorderGreen = const Color(0xFF028958);
Color sherlockLightGreen = const Color(0xFFE8F3F5);

class StainParameters extends StatelessWidget {
  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
                "Please enter/edit your blood spatter data in the following table."
                " Your team name and pattern ID will be used to automatically save"
                " your data for you when you run the analysis.",
                style: TextStyle(
                  fontSize: 16,
                  color: sherlockGrey,
                ),
              ),
            ),
            const StainParametersForm(),
          ]),
        ));
  }
} // --- End Stain Parameters Class

// Define a custom Form widget.
class StainParametersForm extends StatefulWidget {
  const StainParametersForm({Key? key}) : super(key: key);

  @override
  StainParametersFormState createState() {
    return StainParametersFormState();
  }
}

// This class holds data related to the form.
class StainParametersFormState extends State<StainParametersForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  // hard-coded values to be removed later
  bool include = true;
  String comment = "";
  int numStains = 3;

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
// --- All the form fields go here --------------------------------------------
          Container(
              width: 340,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: sherlockLightGreen,
                  border: Border.all(width: 2.0, color: sherlockBorderGreen)),
              child: Column(
                children: [
                  const Text(
                    "Stain Number 1",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "α Angle"),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "γ Angle"),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Y Coord."),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Z Coord."),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Include"),
                      FormField(
                          initialValue: true,
                          builder: (FormFieldState<bool> field) {
                            return SizedBox(
                                width: 60,
                                child: Switch(
                                    value: include,
                                    onChanged: (bool val) {
                                      setState(() {
                                        include = val;
                                      });
                                    }));
                          }),
                      SizedBox(
                          width: 200,
                          child: DropdownButtonFormField(
                            hint: const Text("Comment"),
                            items: const [
                              DropdownMenuItem(
                                value: "",
                                child: Text(""),
                              ),
                              DropdownMenuItem(
                                value: "Bad alpha value",
                                child: Text("Bad alpha value"),
                              ),
                              DropdownMenuItem(
                                value: "Bad gamma value",
                                child: Text("Bad gamma value"),
                              ),
                              DropdownMenuItem(
                                value: "Bad Y or Z coordinate",
                                child: Text("Bad Y or Z coordinate"),
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                comment = value.toString();
                              });
                            },
                          ))
                    ],
                  )
                ],
              )),
// --- End form fields --------------------------------------------------------
        ],
      ),
    );
  }
}
