import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
//import 'gl_script.dart' show glScript;
import 'package:expandable/expandable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          child: Column(
            children: <Widget>[
              Documentation_Card(),
              Padding(
                child: Text('Standard String Chart',
                    style: TextStyle(fontSize: 25)),
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
                child: Echarts(
                  //extensions: [glScript],
                  captureAllGestures: true,
                  option: '''
                    {
                        tooltip: {},
    visualMap: {
        max: 10,
        inRange: {
            color: ['#184ba3', '#ff0000']
        }
    },
    xAxis3D: {
        xAxis.position: top,
        type: 'category',
        data: ['12a', '1a', '2a', '3a', '4a', '5a', '6a',
        '7a', '8a', '9a','10a','11a',
        '12p', '1p', '2p', '3p', '4p', '5p',
        '6p', '7p', '8p', '9p', '10p', '11p']
    },
    yAxis3D: {
        
        type: 'category',
        data: ['0', '20', '30','40', '50', '60', '70']
    },
    zAxis3D: {
       
        type: 'value'
    },
    grid3D: {
        boxWidth: 300,
        boxDepth: 90,
        viewControl: {
        },
        light: {
            main: {
                intensity: 1.5,
                shadow: true
            },
            ambient: {
                intensity: 0.3
            }
        }
    },
    series: [{
        type: 'scatter3D',
        data: [[3,6,18],[10,15,3],[3,4,18],[6,2,4],[7,0,12],[8,6,2],[5,4,3],[2,1,0],[0,1,2],[3,4,5]].map(function (item) {
            return {
                value: [item[1], item[0], item[2]],
            }
        }),
        shading: 'lambert',

        label: {
            fontSize: 14,
            borderWidth: 1
        },

        emphasis: {
            label: {
                fontSize: 20,
                color: '#900'
            },
            itemStyle: {
                color: '#000'
            }
        }
    }]
                    }
                  ''',
                ),
                width: 300,
                height: 250,
              ),
              Padding(
                child: Text('Point-of-Origin Estimation Chart',
                    style: TextStyle(fontSize: 25)),
                padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
              ),
              Padding(
                  child: Text(
                      "This cart shows your stain and string data. In addition, the chart shows all of the Point-of-Origin (PO) estimates based on each stain, the average point of intersection and the stain's individual alpha angle. The average point of intersection is extended by a straight line in the X direction. On this line, you will find the average PO based on the data provide",
                      style: TextStyle(color: Colors.grey)),
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0)),
              Container(
                child: Echarts(
                  //extensions: [glScript],
                  captureAllGestures: true,
                  option: '''
                    {
                        tooltip: {},
    visualMap: {
        max: 10,
        inRange: {
            color: ['#184ba3', '#ff0000']
        }
    },
    xAxis3D: {
        xAxis.position: top,
        type: 'category',
        data: ['12a', '1a', '2a', '3a', '4a', '5a', '6a',
        '7a', '8a', '9a','10a','11a',
        '12p', '1p', '2p', '3p', '4p', '5p',
        '6p', '7p', '8p', '9p', '10p', '11p']
    },
    yAxis3D: {
        
        type: 'category',
        data: ['0', '20', '30','40', '50', '60', '70']
    },
    zAxis3D: {
       
        type: 'value'
    },
    grid3D: {
        boxWidth: 300,
        boxDepth: 90,
        viewControl: {
        },
        light: {
            main: {
                intensity: 1.5,
                shadow: true
            },
            ambient: {
                intensity: 0.3
            }
        }
    },
    series: [{
        type: 'scatter3D',
        data: [[3,6,18],[10,15,3],[3,4,18],[6,2,4],[7,0,12],[8,6,2],[5,4,3],[2,1,0],[0,1,2],[3,4,5]].map(function (item) {
            return {
                value: [item[1], item[0], item[2]],
            }
        }),
        shading: 'lambert',

        label: {
            fontSize: 14,
            borderWidth: 1
        },

        emphasis: {
            label: {
                fontSize: 20,
                color: '#900'
            },
            itemStyle: {
                color: '#000'
            }
        }
    }]
                    }
                  ''',
                ),
                width: 300,
                height: 250,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 50, 0, 10),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: Colors.teal[900],
                    child: Text("Save Data as CSV File"),
                    onPressed: () {},
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(0),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: FlatButton(
                    textColor: Colors.black,
                    color: Colors.white,
                    child: Text("Return to Data Entry Page"),
                    onPressed: () {},
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const documentation_text =
    "These represent the blood stains as you mapped them from the pattern.\n\nThis is the averaged point of intersection of all of your strings in the Y-Z plane.\n\nThis is the error associated with the averaged point of intersection of all of your strings in the Y-Z plane.\n\nThis point represents the estiamted Point-of-Origin based on the data you provided.\n\nThis represents the error associated with the estimate of the Point-of-Origin.\n\nThese are the individual points of intersection for each and every string pair(Method 2).\n\nThis represents the PO based on the individual string intersection pairs (Method 2).\n\nThis rectangular volume represents the estimated error in method 2's estimate of the Point-of-Origin.";

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
          color: Colors.greenAccent[100],
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
                  color: Colors.greenAccent[100],
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
