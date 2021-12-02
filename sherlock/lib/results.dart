import 'package:flutter/material.dart';
import 'dataset.dart';

Dataset data = Dataset.empty();

class Results extends StatelessWidget {
  // constructor
  Results(Dataset dataset, {Key? key}) : super(key: key) {
    data = dataset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Results",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}
