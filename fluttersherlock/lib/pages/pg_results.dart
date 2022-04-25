//Results Page
import 'package:flutter/material.dart';
import 'package:sherlock/models/chart.dart';
import 'package:expandable/expandable.dart';
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
          centerTitle: true,
          backgroundColor: Colors.white,
          bottomOpacity: 0.0,
          elevation: 0.0,
          title: Text(
            "Results",
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: <Widget>[
          Documentation_Card(),
          Padding(
            child:
                Text('Standard String Chart', style: TextStyle(fontSize: 25)),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          Padding(
            child: Text(
              'This chart displays the data you collected as well as the "string" corresponding to the angle data you provided.The view shows all of the stains and strings lying in the Y-Z plane. It also identifies the location of the average point of intersection of all of your lines.',
              style: TextStyle(color: Colors.grey),
            ),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SizedBox(
              width: 300,
              height: 150,
              child: RaisedButton(
                textColor: Colors.black,
                color: Color.fromARGB(255, 200, 255, 216),
                child: Text("View Standard String Chart"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChartPage(chartInfo: processor.chartInfo),
                    ),
                  );
                },
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Padding(
            child: Text('Point-of-Origin Estimation Chart',
                style: TextStyle(fontSize: 25)),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          Padding(
              child: Text(
                  "This chart shows your stain and string data. In addition, the chart shows all of the Point-of-Origin (PO) estimates based on each stain, the average point of intersection and the stain's individual alpha angle. The average point of intersection is extended by a straight line in the X direction. On this line, you will find the average PO based on the data provided.",
                  style: TextStyle(color: Colors.grey)),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0)),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SizedBox(
              width: 300,
              height: 150,
              child: RaisedButton(
                textColor: Colors.black,
                color: Color.fromARGB(255, 200, 255, 216),
                child: Text("View Point-Of-Origin Estimation Chart"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChartPage(chartInfo: processor.chartInfo),
                    ),
                  );
                },
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SizedBox(
              width: 300,
              height: 50,
              child: RaisedButton(
                textColor: Colors.white,
                color: Colors.teal[900],
                child: Text("View All Charts"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChartPage(chartInfo: processor.chartInfo),
                    ),
                  );
                },
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          /*floatingActionButton: ElevatedButton(
        child: const Text("View Graphs"),
        style: ElevatedButton.styleFrom(primary: Colors.teal[900]),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChartPage(chartInfo: processor.chartInfo),
            ),
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
          )*/
        ]))));
  }
}

const documentation_text =
    "These represent the blood stains as you mapped them from the pattern.\n\nThis is the averaged point of intersection of all of your strings in the Y-Z plane.\n\nThis is the error associated with the averaged point of intersection of all of your strings in the Y-Z plane.\n\nThis point represents the estimated Point-of-Origin based on the data you provided.\n\nThis represents the error associated with the estimate of the Point-of-Origin.\n\nThese are the individual points of intersection for each and every string pair(Method 2).\n\nThis represents the PO based on the individual string intersection pairs (Method 2).\n\nThis rectangular volume represents the estimated error in method 2's estimate of the Point-of-Origin.";
const orient_chart =
    "\n\n\nOrienting your charts\nThere are a number of different approaches you can take to adjust the display of each chart. You can use any of the following techniques. They can also be combined to fine tune the look of the chart:\n The rotation axes for these buttons are NOT the chart axes. The rotations are based on the web page's display and may be a bit tricky to get used to at first. As such: \n\tThe X-axis is a line which runs left-to-right in the plane of the screen. \n\tThe Y-axis is a line which runs top-to-bottom in the plane of the screen. \n\tThe Z-axis is an axis which runs in-and-out of the screen.\nThere are an additional six buttons which will help you quickly rotate your chart to one of the more familiar plane views. The first letter on each button represents the axis which will run left-to-right on the display. The second letter will be displayed as the vertical axis.\nFinally, there are two ZOOM buttons which allow you to enlarge or shrink the size of the chart within the display window. At this time, the ZOOM feature will reset the view angle of the chart to its default.";

class Documentation_Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    buildItem(String label) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(label),
      );
    }

    PrintDoc() {
      return Column(
        children: <Widget>[
          Text(
            documentation_text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
          Text(
            orient_chart,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          )
        ],
      );
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: ScrollOnExpand(
        child: Card(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.greenAccent[200],
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToExpand: true,
                  tapBodyToCollapse: true,
                  hasIcon: false,
                ),
                header: Container(
                  color: Colors.greenAccent[200],
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("Documentation",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: PrintDoc(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
