import 'package:flutter/material.dart';
import 'dart:math';

import 'package:sherlock/models/chart.dart';
import '../models/chart.dart';
//import 'canvas_3d.dart';
import 'chart_info.dart';

class StringChart {
  // Canvas canvas;
  // Paint paint;
  // Size size;

  var charts = {};


  
  void plot_2d_chart() async {
    //now create the chart which shows the strings extended into 3D based on the calculated impact heights for each string.
    //The Y-Z coordinates will be forced to the averaged point-of-intersection(POI) while the X values wil be calculated based
    //on the alpha angle and the stain's distance to the POI.

    // // chartInfo.x_low = chartInfo.params.convergenceX - chartInfo.params.cpXStd;
    // // chartInfo.x_high = chartInfo.params.convergenceX + chartInfo.params.cpXStd;

    // // chartInfo.po_err += chartInfo.shiftPlot(
    // //         chartInfo.x_low, chartInfo.y_low, chartInfo.z_low) +
    // //     chartInfo.shiftPlot(
    // //         chartInfo.x_high, chartInfo.y_low, chartInfo.z_low) +
    // //     chartInfo.shiftPlot(
    // //         chartInfo.x_high, chartInfo.y_high, chartInfo.z_low) +
    // //     chartInfo.shiftPlot(chartInfo.x_low, chartInfo.y_high, chartInfo.z_low);
    // // chartInfo.po_err += chartInfo.shiftPlot(
    // //         chartInfo.x_low, chartInfo.y_low, chartInfo.z_high) +
    // //     chartInfo.shiftPlot(
    // //         chartInfo.x_high, chartInfo.y_low, chartInfo.z_high) +
    // //     chartInfo.shiftPlot(
    // //         chartInfo.x_high, chartInfo.y_high, chartInfo.z_high) +
    // //     chartInfo.shiftPlot(
    // //         chartInfo.x_low, chartInfo.y_high, chartInfo.z_high);
    // // chartInfo.po_err_e =
    // //     "[0,1],[1,2],[2,3],[3,0],[0,4],[4,5],[5,6],[6,7],[7,4],[7,3],[6,2],[5,1]";

    // // createChart2();
    // //createChart3();
  }

 
  // Future<void> _createChart2(Canvas canvas, Paint paint, Size size) async {
  //   Canvas3D chart = Canvas3D(canvas, paint, size);
  //   charts['chart2'] = chart;
  //   // changed max_x,y,z for chartInfo.last_x,y,z to extend range for all axes (better visuals on the angles)

  //   var axes = {
  //     'edgeColour': 0x11111100,
  //     'nodes': [
  //       _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.params.min_z),
  //       _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
  //       _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
  //       _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
  //       //draw the axes
  //       _shiftPlot(
  //           cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z - 2.0),
  //       _shiftPlot(cInfo.last_x, cInfo.params.min_y, cInfo.params.min_z),
  //       _shiftPlot(
  //           cInfo.last_x - 2.0, cInfo.params.min_y, cInfo.params.min_z + 2.0),
  //       //draw the arrow heads
  //       _shiftPlot(
  //           cInfo.params.min_x - 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
  //       _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z),
  //       _shiftPlot(
  //           cInfo.params.min_x + 2.0, cInfo.params.min_y, cInfo.last_z - 2.0),
  //       _shiftPlot(
  //           cInfo.params.min_x - 2.0, cInfo.last_y - 2.0, cInfo.params.min_z),
  //       _shiftPlot(cInfo.params.min_x, cInfo.last_y, cInfo.params.min_z),
  //       _shiftPlot(
  //           cInfo.params.min_x + 2.0, cInfo.last_y - 2.0, cInfo.params.min_z),
  //     ],
  //     'edges': [
  //       [0, 1],
  //       [0, 2],
  //       [0, 3],
  //       [4, 5],
  //       [5, 6],
  //       [4, 6],
  //       [7, 8],
  //       [8, 9],
  //       [7, 9],
  //       [10, 11],
  //       [11, 12],
  //       [12, 10]
  //     ],
  //   };

  //   var axeslabels = {
  //     'nodes': [
  //       _shiftPlot(cInfo.last_x + 2.0, cInfo.params.min_y, cInfo.params.min_z),
  //       _shiftPlot(cInfo.params.min_x, cInfo.last_y + 2.0, cInfo.params.min_z),
  //       _shiftPlot(cInfo.params.min_x, cInfo.params.min_y, cInfo.last_z + 2.0),
  //     ],
  //     'text': ["x", "y", "z"],
  //   };

  //   var xtics = {
  //     'edgeColour': 0x11111100,
  //     'nodes': cInfo.x_ticks,
  //     'edges': cInfo.x_edges
  //   };

  //   var xtlabels = {'nodes': cInfo.x_lbl_c, 'text': cInfo.x_lbl};

  //   var ytics = {
  //     'edgeColour': 0x11111100,
  //     'nodes': cInfo.y_ticks,
  //     'edges': cInfo.y_edges
  //   };

  //   var ytlabels = {'nodes': cInfo.y_lbl_c, 'text': cInfo.y_lbl};

  //   var ztics = {
  //     'edgeColour': 0x11111100,
  //     'nodes': cInfo.z_ticks,
  //     'edges': cInfo.z_edges
  //   };

  //   var ztlabels = {'nodes': cInfo.z_lbl_c, 'text': cInfo.z_lbl};

  //   var stains = {
  //     // dots for each stain
  //     'nodeColour': 0xBB222200,
  //     'nodes': cInfo.stains,
  //     'size': 2.0
  //   };

  //   var stainlabels = {
  //     // line // for each stain
  //     'nodes': cInfo.label_coord,
  //     'text': cInfo.label
  //   };

  //   var stainlabel3D = {
  //     // line // for each stain
  //     'nodes': cInfo.end_3Dlabel_coord,
  //     'text': cInfo.end_3Dlabel
  //   };

  //   var po = {
  //     // lines from the stains to the AO
  //     'edgeColour': 0x00AA0000,
  //     'nodes': cInfo.po_nodes,
  //     'edges': cInfo.po_edges
  //   };
  //   if (cInfo.Excluded_strings) {
  //     var exclPo = {
  //       // lines for the excluded strings
  //       'edgeColour': 0xFFFF0000,
  //       'nodes': cInfo.excl_po_nodes,
  //       'edges': cInfo.excl_po_edges
  //     };
  //   }

  //   var poerr = {
  //     // box around the calculated AO
  //     'edgeColour': 0x55005500,
  //     'nodes': cInfo.po_err,
  //     'edges': cInfo.po_err_e
  //   };

  //   var poi = {
  //     // point in the XY plane to find the X value (height) of the AO
  //     'nodeColour': 0x00FFFF00,
  //     'nodes': cInfo.poi,
  //     'size': 2.0
  //   };

  //   var poierr = {
  //     // error bounds for the poi location
  //     'edgeColour': 0x00AAAA00,
  //     'nodes': cInfo.poi_err,
  //     'edges': cInfo.poi_err_e
  //   };

  //   var poiline = {
  //     // line from the XY plane to the averaged Z coordiante for the AO
  //     'edgeColour': 0x0000AA00,
  //     'nodes': cInfo.poi_line,
  //     'edges': [
  //       [0, 1]
  //     ],
  //     'size': 2.0
  //   };

  //   var avgpo = {
  //     // The actual calculated AO
  //     'nodeColour': 0x00004400,
  //     'nodes': cInfo.avg_po,
  //     'size': 2.0
  //   };

  //   //     chart.shapes.add(axes);
  //   //     chart.shapes.add(axeslabels);
  //   //     chart.shapes.add(xtics);
  //   //     chart.shapes.add(xtlabels);
  //   //     chart.shapes.add(ytics);
  //   //     chart.shapes.add(ytlabels);
  //   //     chart.shapes.add(ztics);
  //   //     chart.shapes.add(ztlabels);

  //   //     chart.shapes.add(stains);
  //   //     chart.shapes.add(stainlabels);
  //   //     chart.shapes.add(stainlabel3D);
  //   //     chart.shapes.add(po);
  //   //     chart.shapes.add(poi);
  //   //     chart.shapes.add(poierr);
  //   //     chart.shapes.add(poiline);
  //   //     if(Excluded_strings)
  //   //     {
  //   //        chart.shapes.add(excl_po);
  //   //     }
  //   //     chart.shapes.add(avgpo);
  //   //     chart.shapes.add(poerr);

  //   //     chart.setRotateCentre(x_offset,  y_offset,  z_offset);
  //   //     chart.rotateY(1.570796);

  //   //    chart.camera = [[camera_x, 0, 0], [0, camera_y, 0], [0, 0,camera_z]];   // bring the camera inward to get a larger chart.
  //   //    chart.draw();
  // } // endsub createChart2

//  other useful routines from the canvas js scripts -to see if they still work when included here
//  --- everything from here down is data and chart independent -----------------------------------------------------
//
//      Place it its own js file (or block add to the bottom of current user's js file)
//


}
