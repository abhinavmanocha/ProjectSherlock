import 'dart:math';

import 'package:sherlock/services/chart_info.dart';

class Chart {
  bool changed = false;
  num x_offset;
  num y_offset;
  num z_offset;
  num camera_x = 1.0;
  num camera_y = 1.0;
  num camera_z = 1.0;
  double rotation_angle_increment = 0.05;

  var highlightNodes = {};
  var highlightEdges = {};

  var shapes = [];
  List<num> rotateCentre = [0, 0, 0];
  List<num> dragOffset = [0, 0];

  List<List<num>> camera = [
    [1, 0, 0],
    [0, 1, 0],
    [0, 0, 1]
  ];

  int currentChart = 1;

  ChartInfo cInfo;

  Chart(this.cInfo)
      : x_offset = cInfo.params.min_x + cInfo.shift_size,
        y_offset = cInfo.params.min_y + cInfo.shift_size,
        z_offset = cInfo.params.min_z + cInfo.shift_size;

  List<double> _shiftPlot(num x, num y, num z) {
    return [x + cInfo.shift_size, y + cInfo.shift_size, z + cInfo.shift_size];
  } // end _shiftPlot

  createChart() {
    currentChart = 1;
    var axes = {
      'edgeColour': 0xFF111111,
      'nodes': [
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
        _shiftPlot(
            cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z - 2.0),
        _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(
            cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z + 2.0),
        _shiftPlot(
            cInfo.params.min_x - 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
        _shiftPlot(
            cInfo.params.min_x + 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
        _shiftPlot(
            cInfo.params.min_x - 2.0, cInfo.last_y - 2.0, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
        _shiftPlot(
            cInfo.params.min_x + 2.0, cInfo.last_y - 2.0, cInfo.params.min_z)
      ],
      'edges': [
        [0, 1],
        [0, 2],
        [0, 3],
        [4, 5],
        [5, 6],
        [4, 6],
        [7, 8],
        [8, 9],
        [7, 9],
        [10, 11],
        [11, 12],
        [12, 10]
      ],
    };

    var axeslabels = {
      'nodes': [
        _shiftPlot(cInfo.last_x + 2.0, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y + 2.0, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z + 2.0),
      ],
      'text': ["x", "y", "z"]
    };
    var xtics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.x_ticks,
      'edges': cInfo.x_edges
    };
    var xtlabels = {'nodes': cInfo.x_lbl_c, 'text': cInfo.x_lbl};
    var ytics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.y_ticks,
      'edges': cInfo.y_edges
    };
    var ytlabels = {'nodes': cInfo.y_lbl_c, 'text': cInfo.y_lbl};
    var ztics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.z_ticks,
      'edges': cInfo.z_edges
    };
    var ztlabels = {'nodes': cInfo.z_lbl_c, 'text': cInfo.z_lbl};
    var stains = {'nodeColour': 0xFFBB2222, 'nodes': cInfo.stains, 'size': 2};
    var stainlabels = {'nodes': cInfo.label_coord, 'text': cInfo.label};
    var endstainlabels = {
      'nodes': cInfo.end_label_coord,
      'text': cInfo.end_label
    };
    var strings = {
      'edgeColour': 0xFF22AA22,
      'nodes': cInfo.strings_nodes,
      'edges': cInfo.string_edges
    };

    var exclstrings = {};
    if (cInfo.Excluded_strings) {
      exclstrings['edgeColour'] = 0xFFFFFF00;
      exclstrings['nodes'] = cInfo.exclude_strings;
      exclstrings['edges'] = cInfo.exclude_edges;
    } // if there are excluded strings

    var poi = {
      'nodeColour': 0xFF000000, // ellipse(ball.x, ball.y, ball.r*2, ball.r*2);
      'nodes': cInfo.poi,
      'size': 2
    };

    var poierr = {
      'edgeColour': 0xFFEE0000, //  '0xCC0099'    XZ plane plot.
      'nodes': cInfo.poi_err,
      'edges': cInfo.poi_err_e
    };

    shapes.add(axes);
    shapes.add(axeslabels);
    shapes.add(xtics);
    shapes.add(xtlabels);
    shapes.add(ytics);
    shapes.add(ytlabels);
    shapes.add(ztics);
    shapes.add(ztlabels);
    shapes.add(stains);
    shapes.add(stainlabels);
    shapes.add(endstainlabels);
    shapes.add(strings);
    // if there are excluded strings
    if (cInfo.Excluded_strings) {
      shapes.add(exclstrings);
    }
    shapes.add(poi);
    shapes.add(poierr);
  print(x_offset);
  print(y_offset);
  print(z_offset);
  print("");
    setRotateCentre(x_offset, y_offset, z_offset);
    rotateY(1.570796);

    // bring the camera inward to get a larger chart.
    camera = [
      [camera_x, 0, 0],
      [0, camera_y, 0],
      [0, 0, camera_z]
    ];

    moveCamera('+', 3);
    viewXYplane('+');
  } //end function createChart1

  createChart2() {
    currentChart = 2;

    // changed max_x,y,z for chartInfo.last_x,y,z to extend range for all axes (better visuals on the angles)
    var axes = {
      'edgeColour': 0xFF111111,
      'nodes': [
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
        //draw the axes
        _shiftPlot(
            cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z - 2.0),
        _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(
            cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z + 2.0),
        //draw the arrow heads
        _shiftPlot(
            cInfo.params.min_x - 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
        _shiftPlot(
            cInfo.params.min_x + 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
        _shiftPlot(
            cInfo.params.min_x - 2.0, cInfo.last_y - 2.0, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
        _shiftPlot(
            cInfo.params.min_x + 2.0, cInfo.last_y - 2.0, cInfo.params.min_z),
      ],
      'edges': [
        [0, 1],
        [0, 2],
        [0, 3],
        [4, 5],
        [5, 6],
        [4, 6],
        [7, 8],
        [8, 9],
        [7, 9],
        [10, 11],
        [11, 12],
        [12, 10]
      ],
    };

    var axeslabels = {
      'nodes': [
        _shiftPlot(cInfo.last_x + 2.0, cInfo.params.min_y, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.last_y + 2.0, cInfo.params.min_z),
        _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z + 2.0),
      ],
      'text': ["x", "y", "z"],
    };

    var xtics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.x_ticks,
      'edges': cInfo.x_edges
    };

    var xtlabels = {'nodes': cInfo.x_lbl_c, 'text': cInfo.x_lbl};

    var ytics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.y_ticks,
      'edges': cInfo.y_edges
    };

    var ytlabels = {'nodes': cInfo.y_lbl_c, 'text': cInfo.y_lbl};

    var ztics = {
      'edgeColour': 0xFF111111,
      'nodes': cInfo.z_ticks,
      'edges': cInfo.z_edges
    };

    var ztlabels = {'nodes': cInfo.z_lbl_c, 'text': cInfo.z_lbl};

    var stains = {
      // dots for each stain
      'nodeColour': 0xFFBB2222,
      'nodes': cInfo.stains,
      'size': 2.0
    };

    var stainlabels = {
      // line // for each stain
      'nodes': cInfo.label_coord,
      'text': cInfo.label
    };

    var stainlabel3D = {
      // line // for each stain
      'nodes': cInfo.end_3Dlabel_coord,
      'text': cInfo.end_3Dlabel
    };

    var po = {
      // lines from the stains to the AO
      'edgeColour': 0xFF00AA00,
      'nodes': cInfo.po_nodes,
      'edges': cInfo.po_edges
    };

    var exclPo = {};
    if (cInfo.Excluded_strings) {
      exclPo['edgeColour'] = 0xFFFFFF00;
      exclPo['nodes'] = cInfo.excl_po_nodes;
      exclPo['edges'] = cInfo.excl_po_edges;
    }

    var poerr = {
      // box around the calculated AO
      'edgeColour': 0xFF550055,
      'nodes': cInfo.po_err,
      'edges': cInfo.po_err_e
    };

    var poi = {
      // point in the XY plane to find the X value (height) of the AO
      'nodeColour': 0xFF00FFFF,
      'nodes': cInfo.poi,
      'size': 2.0
    };

    var poierr = {
      // error bounds for the poi location
      'edgeColour': 0xFF00AAAA,
      'nodes': cInfo.poi_err,
      'edges': cInfo.poi_err_e
    };

    var poiline = {
      // line from the XY plane to the averaged Z coordiante for the AO
      'edgeColour': 0xFF0000AA,
      'nodes': cInfo.poi_line,
      'edges': [
        [0, 1]
      ],
      'size': 2.0
    };

    var avgpo = {
      // The actual calculated AO
      'nodeColour': 0xFF000044,
      'nodes': cInfo.avg_po,
      'size': 2.0
    };

    shapes.add(axes);
    shapes.add(axeslabels);
    shapes.add(xtics);
    shapes.add(xtlabels);
    shapes.add(ytics);
    shapes.add(ytlabels);
    shapes.add(ztics);
    shapes.add(ztlabels);

    shapes.add(stains);
    shapes.add(stainlabels);
    shapes.add(stainlabel3D);
    shapes.add(po);
    shapes.add(poi);
    shapes.add(poierr);
    shapes.add(poiline);
    if (cInfo.Excluded_strings) {
      shapes.add(exclPo);
    }
    shapes.add(avgpo);
    shapes.add(poerr);
  print(x_offset);
  print(y_offset);
  print(z_offset);

    setRotateCentre(x_offset, y_offset, z_offset);
    rotateY(1.570796);

    camera = [
      [camera_x, 0, 0],
      [0, camera_y, 0],
      [0, 0, camera_z]
    ]; // bring the camera inward to get a larger

  } // endsub createChart2

  void setRotateCentre(num x, num y, num z) {
    for (var shape in shapes) {
      for (List n in shape['nodes']) {
        n[0] -= x;
        n[1] -= y;
        n[2] -= z;
      }
    }
    rotateCentre = [x, y, z];
  }

  void rotateX(double theta) {
    var c = cos(theta);
    var s = sin(theta);
    List<List<double>> T = [
      [1, 0, 0],
      [0, c, -s],
      [0, s, c]
    ];

    camera = cameraTransform(T);
    //draw();
  }

  void rotateY(double theta) {
    var c = cos(theta);
    var s = sin(theta);
    List<List<double>> T = [
      [c, 0, s],
      [0, 1, 0],
      [-s, 0, c]
    ];

    camera = cameraTransform(T);
    //draw();
  }

  void rotateZ(double theta) {
    var c = cos(theta);
    var s = sin(theta);
    List<List<double>> T = [
      [c, -s, 0],
      [s, c, 0],
      [0, 0, 1]
    ];

    camera = cameraTransform(T);
    //draw();
  }

  // Multiply camera matrix by 3x3 transform matrix, T
  List<List<double>> cameraTransform(List<List<double>> T) {
    List<List<double>> newMatrix = [];
    // for (var row in T) {
    for (int row = 0; row < T.length; row++) {
      var t = T[row];
      List<double> newRow = [];
      newRow
          .add(t[0] * camera[0][0] + t[1] * camera[1][0] + t[2] * camera[2][0]);
      newRow
          .add(t[0] * camera[0][1] + t[1] * camera[1][1] + t[2] * camera[2][1]);
      newRow
          .add(t[0] * camera[0][2] + t[1] * camera[1][2] + t[2] * camera[2][2]);
      newMatrix.add(newRow);
    }
    return newMatrix;
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Originally External
  //////////////////////////////////////////////////////////////////////////////

  void rotateButton(axis, direction) {
    double angleTweak = rotation_angle_increment;

    if (direction != '+') {
      angleTweak = -rotation_angle_increment;
    }

    // the axis of rotation is the CANVAS and not the chart axes. So in-out of the screen in the canvas-Z axis
    switch (axis) {
      // right-to-left is the canvas-X axis and top-to-bottom is the canvas-Y rotation axis.
      case "x":
        rotateX(angleTweak);
        break;
      case "y":
        rotateY(angleTweak);
        break;
      case "z":
        rotateZ(angleTweak);
        break;
    } // end switch

    //draw();
  }

  void moveCamera(direction, num amount) {
    switch (direction) {
      case "+":
        camera_x += amount;
        camera_y += amount;
        camera_z += amount;

        camera = [
          [camera_x, 0, 0],
          [0, camera_y, 0],
          [0, 0, camera_z]
        ];
        break;
      case "-":
        camera_x -= amount;
        camera_y -= amount;
        camera_z -= amount;

        camera = [
          [camera_x, 0, 0],
          [0, camera_y, 0],
          [0, 0, camera_z]
        ];
        break;
    } // end switch
    //draw();
  }

  void viewYZplane(direction) {
    camera = [
      [camera_x, 0, 0],
      [0, camera_y, 0],
      [0, 0, camera_z]
    ];

    switch (direction) {
      case "+":
        rotateY(1.570796); // 90 degrees in the canvas Y
        break;
      case "-":
        rotateX(-1.570796); // 90 degrees in the canvas Y
        rotateY(-1.570796); // 90 degrees in the canvas Y
        break;
    } // end switch

    //draw();
  }

  void viewXYplane(String direction) {
    camera = [
      [camera_x, 0, 0],
      [0, camera_y, 0],
      [0, 0, camera_z]
    ];

    switch (direction) {
      case "+":
        rotateX(3.1415926); //180 degrees in the canvas X
        //(axis goes left to right on canvas)
        rotateZ(1.570796); // 90 degrees in the canvas Z
        //(axis goes in and out of the screen/canvas)
        break;
      case "-":
        camera = [
          [camera_x, 0, 0],
          [0, camera_y, 0],
          [0, 0, camera_z]
        ];
        // chart.rotateZ(1.570796);  // 90 degrees in the canvas Y
        break;
    } // end switch

    //chart.draw();
  }

  void viewXZplane(String direction) {
    camera = [
      [camera_x, 0, 0],
      [0, camera_y, 0],
      [0, 0, camera_z]
    ];

    switch (direction) {
      case "+":
        rotateY(1.570796); // 90 degrees in the canvas X
        rotateX(1.570796); // 90 degrees in the canvas X
        break;
      case "-":
        rotateX(-1.570796); // 90 degrees in the canvas X
        break;
    } // end switch

    //draw();
  }
}
