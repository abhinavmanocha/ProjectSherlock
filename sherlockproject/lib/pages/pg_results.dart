import 'package:flutter/material.dart';
import 'package:sherlock/models/chart.dart';

import 'pg_chart.dart';
import '../models/blood_sample.dart';
import '../models/output.dart';
import '../services/processor.dart';
import '../models/results_param.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key, required this.sample}) : super(key: key);
  final BloodSample sample;

  @override
  Widget build(BuildContext context) {
    ResultParameters resultsParams = ResultParameters(sample);
    DataProcessor processor = DataProcessor(resultsParams);
    processor.params.detailed = true;
    Future<List<Output>> futureResult = processor.process();

    // Text _getPOI() {
    //   return Text('0');
    // }

    Widget genText(var data) {
      if (data.type == Output.bold || data.type == Output.title) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            data.content,
            softWrap: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        return Text(data.content, softWrap: true);
      }
    }

    Widget _buildTextLate() {
      return FutureBuilder(
          future: futureResult,
          builder:
              (BuildContext context, AsyncSnapshot<List<Output>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text(
                  '${snapshot.error} occured',
                  style: const TextStyle(fontSize: 18),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data!;

                final children = <Widget>[
                  for (int i = 0; i < data.length; i++) genText(data[i]),
                ];

                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: children);
              }
            }
            // Displaying LoadingSpinner to indicate waiting state
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: ElevatedButton(
                  child: const Text("View Graphs"),
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChartPage(chartInfo: processor.chartInfo),),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 15.0,
          ),
          child: _buildTextLate(),
        ),
      ),
    );
  }
}
