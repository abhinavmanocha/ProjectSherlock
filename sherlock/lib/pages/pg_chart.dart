import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sherlock/models/chart.dart';
import 'package:sherlock/services/canvas_3d.dart';
import 'package:sherlock/services/chart_info.dart';



// final display = createDisplay(decimal: 2);
class ChartPage extends StatelessWidget {
  const ChartPage({Key? key, required this.chartInfo}) : super(key: key);
  final ChartInfo chartInfo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChartHomePage(chartInfo: chartInfo),
    );
  }
}

class ChartHomePage extends StatefulWidget {
  const ChartHomePage({required this.chartInfo, Key? key}) : super(key: key);
  final ChartInfo chartInfo;

  @override
  _ChartHomePageState createState() => _ChartHomePageState();
}

class _ChartHomePageState extends State<ChartHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  late Chart chart;
  late Canvas3D canvas3D;
  late int currentChart;

  @override
  initState() {
    super.initState();
    currentChart = 1;
    chart = Chart(widget.chartInfo);
    chart.createChart1();
    chart.createChart2();    
    canvas3D = Canvas3D(chart, repaint: _counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text("String Graphs"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.0),
      endDrawer: Drawer(
        backgroundColor: Colors.tealAccent,
        child: ListView(padding: const EdgeInsets.all(8), children: [
          const DrawerHeader(
            child: Text("Reset Viewpoint"),
            decoration: BoxDecoration(color: Colors.teal),
          ),
          ListTile(
            leading: const Icon(Icons.zoom_out),
            title: Text("View Chart ${currentChart == 1 ? 2 : 1}"),
            onTap: () {
              if (currentChart == 1) {
                setState(() {
                  canvas3D.changeGraph(2);
                  currentChart = 2;
                  _counter.value++;
                });
              } else {
                setState(() {
                  canvas3D.changeGraph(1);
                  currentChart = 1;
                  _counter.value--;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_out),
            title: const Text("View X-Y Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewXYplane('-');
                _counter.value--;
              });
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.gear_alt),
            title: const Text("View X-Z Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewXZplane('+');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.gear_alt),
            title: const Text("View Y-X Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewXYplane('+');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.gear_alt),
            title: const Text("View Y-Z Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewYZplane('-');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.gear_alt),
            title: const Text("View Z-X Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewXZplane('-');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.gear_alt),
            title: const Text("View Z-Y Plane"),
            onTap: () {
              setState(() {
                canvas3D.viewYZplane('+');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: const Text("Zoom In"),
            onTap: () {
              setState(() {
                canvas3D.moveCamera('+');
                _counter.value++;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_out),
            title: const Text("Zoom Out"),
            onTap: () {
              setState(() {
                canvas3D.moveCamera('-');
                _counter.value++;
              });
            },
          ),
        ]),
      ),
      floatingActionButton: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("X+"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('x', '+');
                    _counter.value++;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("X-"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('x', '-');
                    _counter.value++;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("Y+"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('y', '+');
                    _counter.value++;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("Y-"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('y', '-');
                    _counter.value++;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("Z+"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('z', '+');
                    _counter.value++;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.teal),
                child: const Text("Z-"),
                onPressed: () {
                  setState(() {
                    canvas3D.rotateButton('z', '-');
                    _counter.value++;
                  });
                },
              ),
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Container(
                height: 600,
                color: Colors.yellow,
                child: ListView.builder(
                  itemCount: 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: 600,
                      color: Colors.white,
                      child: CustomPaint(
                        painter: canvas3D,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
