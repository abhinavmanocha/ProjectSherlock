import 'package:flutter/material.dart';

Color sherlockGrey = const Color(0xFF7C7C7C);
Color sherlockDarkGreen = const Color(0xFF215A47);
Color sherlockBorderGreen = const Color(0xFF028958);
Color sherlockLightGreen = const Color(0xFFE8F3F5);

class StainParameters extends StatelessWidget {
  const StainParameters({Key? key}) : super(key: key);

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
                // Navigate back to first route when tapped.
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
            )
          ]),
        ));
  }
}
