import 'package:intl/intl.dart';

import '../models/output.dart';
import '../models/results_param.dart';

class ChartInfo {
  ResultParameters params;
  //
  //   preparing for the javascript canvas graphs
  //
  //   we need to save two additional files based on the analysis sample:
  //Contains the JavaScript constructs and 3D data points and lines for the charts specific to this analysis
  //
  //  We also need additional memory to store:
  //     BloodStain Y-Z coordinates                                      - $stains [x,y,z], [x,y,z]...
  //                                                                            where x is always =0,
  //                                       
  //    Teamname_PatternID.html  - contains the canvas and 3D charts for the analysis
  //    Teamname_PatternID.js    -                               - $stain_label_coord, $stain_label
  //     String start and end points                                     - $strings_nodes [x,y,z], [x,y,z]...]
  //                                                                            and $string_edges [ 0,1],[2,3]...]
  //     the coordinates in the Y-Z plane of the point of intersection   - $poi  [0,y,z]
  //     The string data for the strings leading to the Point-of-Origin  - $po_nodes [x,y,z], [x,y,z]...]
  //                                                                              and $po_edges [ 0,1],[2,3]...]
  //     The coordinates of the averaged Point-of-Origin                 - $avg_po  [x,y,z]

  List<List<double>> stains = [];
  List<List<double>> label_coord = [];
  List<String> label = [];
  List<List<double>> end_label_coord = [];
  List<String> end_label = [];
  List<List<double>> end_3Dlabel_coord = [];
  List<String> end_3Dlabel = [];

  List<List<double>> strings_nodes = [];
  List<List<int>> string_edges = [];

  List<List<double>> exclude_strings =
      []; // in case the user decided to exclude specific lines.
  List<List<int>> exclude_edges = [];
  int exclude_count = 0;

  int str_edge_count = 0;

  List<List<double>> poi = [];
  List<List<double>> poi_err = [];
  List<List<int>> poi_err_e = [];
  List<List<double>> poi_line = [];

  String cloud_poi = "";
  String cloud_err = "";
  String cloud_edges = "";
  String cloud_centre = "";

  List<List<double>> po_err = [];
  List<List<double>> po_err_e = [];

  List<List<double>> po_nodes = [];
  List<List<int>> po_edges = [];
  // will be the same as str_edge_count because it is based on the number of stains :-)
  int po_edge_count = 0;
  // to tag and identify in the chart lines removed from the calculations.
  List<List<double>> excl_po_nodes = [];
  List<List<int>> excl_po_edges = [];
  // will be the same as str_edge_count because it is based on the number of stains :-)
  int excl_po_edge_count = 0;

  List<List<double>> avg_po = [];

  double shift_size =
      100; //Need to shift plot corrdinates to canvas coordinates

  List<List<double>> x_ticks = [];
  List<List<double>> x_lbl_c = [];
  List<String> x_lbl = [];
  List<List<int>> x_edges = [];

  List<List<double>> y_ticks = [];
  List<List<double>> y_lbl_c = [];
  List<String> y_lbl = [];
  List<List<int>> y_edges = [];

  List<List<double>> z_ticks = [];
  List<List<double>> z_lbl_c = [];
  List<String> z_lbl = [];
  List<List<int>> z_edges = [];

  num last_x = 0, last_y = 0, last_z = 0;
  double x_low = 0.0, x_high = 0.0;
  double z_low = 0.0, z_high = 0.0;
  double y_low = 0.0, y_high = 0.0;
  bool Excluded_strings = false;

  ChartInfo(this.params);

  //----------------------------------------------------------------------------------------------------
  //
  //  Need to shift all coordinates away from (0,0,0) so they can be plotted properly.
  //  This routine accepts (x,y,z) coordinates and returns a string formatted as "[x+xshift,y+yshift,z+zshift],"
  //
  //
  String shiftPlot(double x, double y, double z) {
    return "[${(x + shift_size).toStringAsFixed(2)},"
        "${(y + shift_size).toStringAsFixed(2)},"
        "${(z + shift_size).toStringAsFixed(2)}]";
  } // endsub shiftPlot

  List<double> _shiftPlot(double x, double y, double z) {
    return [x + shift_size, y + shift_size, z + shift_size];
  } // end _shiftPlot

  //---------------------------------------------------------------------------------------------
  //
  //  The plot_2d_chart routine is used to draw the "strings" required for the analysis. The strings
  //  start at each blood stain and are drawn according to the gamma angle supplied by the user. The
  //  strings are drawn from the stain until the string extends beyond the borders of the chart. At
  //  that time, the strings are "clipped" to fit into the chart.
  //
  //  The "height" variable contains the estimated height in the Z direction of the AO.
  //
  //  We should have unique X,Y and Z coordinates for each stain's origin. We can also calculate
  //  additional coordinates along the line so we can draw the string.

  Future<List<Output>> plot_2d_chart() async {
    List<Output> outputs = [];
    NumberFormat f = NumberFormat("##0.0#");

    if (params.detailed) {
      outputs
          .add(Output("Number of data points:${params.sample.numStains}:\n"));
    }
    for (int i = 0; i < params.sample.numStains; i++) {
      if (params.sample.bloodStains[i].x < params.min_x) {
        params.min_x = params.sample.bloodStains[i].x;
      } // from the dataset determine the boundaries of the chart
      if (params.sample.bloodStains[i].x > params.max_x) {
        params.max_x = params.sample.bloodStains[i].x;
      }
      if (params.sample.bloodStains[i].y < params.min_y) {
        params.min_y = params.sample.bloodStains[i].y;
      } // from the dataset determine the boundaries of the chart
      if (params.sample.bloodStains[i].y > params.max_y) {
        params.max_y = params.sample.bloodStains[i].y;
      }
      if (params.sample.bloodStains[i].z < params.min_z) {
        params.min_z = params.sample.bloodStains[i].z;
      }
      if (params.sample.bloodStains[i].z > params.max_z) {
        params.max_z = params.sample.bloodStains[i].z;
      }

      if (params.sample.bloodStains[i].height < params.min_height) {
        params.min_height = params.sample.bloodStains[i].height;
      } // from the individual heights, find the largest X axis value from the dataset
      if (params.sample.bloodStains[i].height > params.max_height) {
        params.max_height = params.sample.bloodStains[i].height;
      }
    } // end for to count valid entries to save.

    if (params.convergenceX < params.min_x) {
      params.min_x = params.convergenceX;
    } // if the convergence point is outside of the plot, adjust the boundaries accordingly
    if (params.convergenceX > params.max_x) {
      params.max_x = params.convergenceX;
    }
    if (params.convergenceY < params.min_y) {
      params.min_y = params.convergenceY;
    } // if the convergence point is outside of the plot, adjust the boundaries accordingly
    if (params.convergenceY > params.max_y) {
      params.max_y = params.convergenceY;
    }
    if (params.convergenceZ < params.min_z) {
      params.min_z = params.convergenceZ;
    }
    if (params.convergenceZ > params.max_z) {
      params.max_z = params.convergenceZ;
    }

    params.max_x = 1.1 * params.max_x; // make whitespace around the line chart
    params.min_x = 0.9 * params.min_x;
    params.max_y = 1.1 * params.max_y; // make whitespace around the line chart
    params.min_y = 0.9 * params.min_y;
    params.max_z = 1.1 * params.max_z;
    params.min_z = 0.9 * params.min_z;

    params.min_height = 0.9 * params.min_height;
    params.max_height = 1.1 * params.max_height;

    // if( params.min_x > params.min_height ) { params.min_x = params.min_height; }
    // if( params.max_x < params.max_height ) { params.max_x = params.max_height; }

    if (params.detailed) {
      outputs.add(Output(
          "Blood Source Location: ${f.format(params.convergenceX)} ${f.format(params.convergenceY)} ${f.format(params.convergenceZ)} \n"));
      outputs.add(Output("Chart dimensions:"));
      outputs.add(Output(
          "Height(Z of AO) Min=${params.min_height} Max=${params.max_height}"));
      outputs.add(Output("X Min=${params.min_x} Max=${params.max_x}"));
      outputs.add(Output("Y Min=${params.min_y} Max=${params.max_y}"));
      outputs.add(Output("Z Min=${params.min_z} Max=${params.max_z}"));
      outputs.add(Output(
          "Convergence point = (${params.convergenceX},${params.convergenceY},${params.convergenceZ});"));
    }

    //  --- at this point in time the chart limits are:
    //          X: [min_height-?max_height]  Y: [min_y->max_y]  Z: [min_z->max_z]
    //
    // Chart object
    //
    //   shoud we be charting from y=0 and z=0 ????
    //
    //
    //  now plot each line.... each line represents a point.
    //

    double start_y = 0;
    double end_y = 0;
    double start_x = 0;
    double end_x = 0;
    double t = 0;
    // bool Excluded_strings = false;
    Excluded_strings = false;

    //
    //   plotting the view of the X-y plane with no Z coordinates for the line (to find the common
    //   point of intersection) to specify the X coordinate of the AO)
    //
    //  This is a 2-D plot (even though you can rotate it in 3D
    //
    for (var i = 0; i < params.sample.numStains; i++) {
      var Py = params.sample.bloodStains[i].y;
      var dy = params.sample.bloodStains[i].deltaY;

      var Px = params.sample.bloodStains[i].x;
      var dx = params.sample.bloodStains[i].deltaX;

      //NB: on as single line
      if (params.detailed) {
        outputs.add(Output("Plotting lines[${i + 1}]:", type: Output.bold));
        outputs.add(Output(
            "Py=${Py.toStringAsFixed(2)} delta_y=${dy.toStringAsFixed(2)}  Px=${Px.toStringAsFixed(2)} Delta_x=${dx.toStringAsFixed(2)}"));
      }
      // By default, assume we don't have a special case for this line
      var special_case = false;

      if (dy == 0.0) {
        //$fake_zero )
        if (params.detailed) {
          outputs.add(Output("Delta y was zero", txtColor: Output.red));
        }
        // the line is vertical on the graph
        special_case = true;
        // Y coordinates are the same for the start and end-point
        start_y = params.sample.bloodStains[i].y;
        end_y = params.sample.bloodStains[i].y;
        start_x = params.min_x;
        end_x = params.max_x;
      }
      if (dx == 0.0) {
        if (params.detailed) {
          outputs.add(Output("Delta x was zero", txtColor: Output.red));
        }
        special_case = true; // the line is horizontal on the graph
        // Y coordinates are the same for the start and end-point
        start_y = params.min_y;
        end_y = params.max_y;
        start_x = params.sample.bloodStains[i].x;
        end_x = params.sample.bloodStains[i].x;
      }

      if (!special_case) {
        if (params.detailed) {
          outputs.add(Output("Not a special case\n"));
        }
        //
        //      make two points one with a positive t value and one with a negative t value. Use these
        //      as the endpoints to the line. We can then clip them as necessary to fit the graph window.
        //      We can calculate how many "t" are required to go from Ymax to Ymin and use this as the guess
        //      for a good value of t to cover the range

        var temp_t = 0.0;
        var guess_t = 0.0;
        // start and end coordinates for the line drawn on the graph (X-Y plane only).
        var sy = 0.0;
        var sx = 0.0;
        var ex = 0.0;
        var ey = 0.0;
        //
        //  Find out the t values for the parametric equation which will allow us to draw a line
        //  from the x axis (y=?, z=0) to the other edge of the graph. These are the projections
        //  of the 3D strings onto the XY plane. They allow us to calculate a value for X for the AO
        //
        //  Since P1x[$i] is always zero, we must use the P1y[$i] to see how long we need to draw the line
        //

        var ty_to_maxy = params.max_y -
            params.sample.bloodStains[i].y; // distance from the max
        var ty_to_miny = params.min_y -
            params.sample.bloodStains[i].y; // distance from the min
        if (params.detailed) {
          outputs.add(Output(
              "ty_to_maxy =$ty_to_maxy = ${params.max_y}-${params.sample.bloodStains[i].y}\n"));
        }
        if (params.detailed) {
          outputs.add(Output(
              "ty_to_miny =$ty_to_miny = ${params.min_y}-${params.sample.bloodStains[i].y}\n"));
        }

        if (ty_to_maxy.abs() > ty_to_miny.abs()) {
          guess_t = ty_to_maxy / dy;
        } else {
          guess_t = ty_to_miny / dy;
        }
        if (params.detailed) {
          outputs.add(Output(
              "ty_to_maxy=$ty_to_maxy ty_to_miny=$ty_to_miny   guess_t=$guess_t\n"));
        }
        //
        //      now we have a t value to extend the line to one end of the string.
        //
        // The X coordinate for all stains is zero. The Y coordiante is just the stain Y coord.
        sy = params.sample.bloodStains[i].y;
        // these coordiantes are always in the XY plane.
        sx = params.sample.bloodStains[i].x;
        ex = params.sample.bloodStains[i].x + (guess_t * dx);
        ey = params.sample.bloodStains[i].y + (guess_t * dy);
        if (params.detailed) {
          outputs.add(Output("Before tweaks\n"));
          outputs.add(Output(
              "\tsy =${params.sample.bloodStains[i].y}\n")); // The X coordinate for all stains is zero. The Y coordiante is just the stain Y coord.
          outputs.add(Output(
              "\tsx =${params.sample.bloodStains[i].x}\n")); // these coordiantes are always in the XY plane.
          outputs.add(Output(
              "\tex (ex) =${params.sample.bloodStains[i].x} + ($guess_t * $dx)\n"));
          outputs.add(Output(
              "\tey (ey) =${params.sample.bloodStains[i].y} + ($guess_t * $dy)\n"));
        }

        //  If the line is pointing in the -ve X direction, we're going the wrong way, reverse the value of t
        if (ex < 0.0) {
          ex = params.sample.bloodStains[i].x + (-1.0 * guess_t * dx);
          ey = params.sample.bloodStains[i].y + (-1.0 * guess_t * dy);
          if (params.detailed) {
            outputs.add(Output(
                "ex was negative, using -t to calculate endpoint ex=$ex ey=$ey\n"));
          }
        }
        //  If we are way past the convergence point, then we don't really need to draw out that far.
        //  shorten the drawn line.
        var end_x_test = (3 * params.convergenceX);
        if (params.detailed) {
          outputs.add(Output("end_x_test=$end_x_test ex=$ex\n"));
        }

        if (ex > end_x_test) {
          if (params.detailed) {
            outputs.add(Output(
                "x endpoint beyond 3*conv_x\nBefore [guess_t=$guess_t] ex=$ex\n"));
          }
          guess_t = end_x_test / dx;
          ex = params.sample.bloodStains[i].x + (guess_t * dx);
          ey = params.sample.bloodStains[i].y + (guess_t * dy);
          if (params.detailed) {
            outputs.add(Output("after [guess_t=$guess_t] ex=$ex\n"));
          }
        }

        if (params.detailed) {
          outputs.add(Output(
              "sy=${params.sample.bloodStains[i].y}\n")); // The X coordinate for all stains is zero. The Y coordiante is just the stain Y coord.
          outputs.add(Output(
              "sx=${params.sample.bloodStains[i].x}\n")); // these coordiantes are always in the XY plane.
          outputs.add(Output(
              "ex ($ex)=${params.sample.bloodStains[i].x} + ($guess_t * $dx)\n"));
          outputs.add(Output(
              "ey ($ey)=${params.sample.bloodStains[i].y} + ($guess_t * $dy)\n"));
        }

        //  ----------------------------------------------------------------------
        start_x = sx;
        end_x = ex;

        start_y = sy;
        end_y = ey;
        if (end_x > params.max_x) {
          params.max_x = end_x;
        } // if the end point of the line > then expand the graph to see it.

        if (params.detailed) {
          outputs.add(Output("draw line from "));
          outputs.add(Output(
              "(${start_x.toStringAsFixed(2)},${start_y.toStringAsFixed(2)}) -> (${end_x.toStringAsFixed(2)},${end_y.toStringAsFixed(2)}\n"));
        }
      } // if not a special case

      //---------------------  strings get built here ------------------------

      //-----  load up stain locations and PO strings from (0,y,z) -> (height,convergence_y,convergence_z);
      //     BloodStain Y-Z coordinates                                      - $stains [x,y,z], [x,y,z]... where x is always =0
      //     String start and end points                                     - $strings_nodes [x,y,z], [x,y,z]...] and $string_edges [ 0,1],[2,3]...]
      //     the coordinates in the Y-Z plane of the point of intersection   - $poi  [0,y,z]
      //     The string data for the strings leading to the Point-of-Origin  - $po_nodes [x,y,z], [x,y,z]...] and $po_edges [ 0,1],[2,3]...]
      //     The coordinates of the averaged Point-of-Origin                 - $avg_po  [x,y,z]
      //

      // ----  js version ------
      //
      //  Draw the stains in their real position in the Y-Z plane. We may need to move/copy the labels
      //  so they show up on the lines themselves so we can quickly identify outliers?
      //
      if (params.detailed) {
        outputs.add(Output(
            "Placing a stain at: (0.0,${params.sample.bloodStains[i].y},${params.sample.bloodStains[i].z})"));
      }
      stains.add(_shiftPlot(
          0.0,
          params.sample.bloodStains[i].y,
          params.sample.bloodStains[i]
              .z)); // place a DOT at the location of each stain on the chart.
      label_coord.add(_shiftPlot(
          0.0,
          params.sample.bloodStains[i].y + 0.6,
          params.sample.bloodStains[i].z +
              0.6)); // put the stain number next to the stain
      label.add("${i + 1}");
      //
      //  duplicate labels to the end of the lines too...  4-june-2018
      //
      end_label_coord.add(_shiftPlot(end_x, end_y + 0.6,
          params.min_z + 0.6)); // put the stain number next to the stain
      end_label.add("${i + 1}");

      //
      // Here we draw the strings in the Y-Z plane.
      //
      //  $strings_nodes: holds the coordiantes of each point
      //  $string_edges : hold the pointers to the node numbers that make up a line segment
      //  $str_edge_count: is increased by 2 because we add two data points at a  time (start,stop) for the lines.
      //
      // If we include a line, we draw it in a normal colour. If a line is excluded from the analysis, we add it
      // to the $exclude_?????? variables so it can be drawn in red
      //
      if (params.detailed) {
        outputs.add(Output(
            "Plotting 2D line from ($start_x,$start_y,0.0) to ($end_x,$end_y,0.0)"));
      }
      if (params.sample.bloodStains[i].include) {
        strings_nodes.addAll([
          _shiftPlot(start_x, start_y, params.min_z),
          _shiftPlot(end_x, end_y, params.min_z)
        ]); // from the blood stain to the edge of the chart in the Y-Z plane
        string_edges.add([
          str_edge_count,
          str_edge_count + 1
        ]); // line from the stain the the endpoint
        str_edge_count += 2;
      } else {
        Excluded_strings = true;
        exclude_strings.addAll([
          _shiftPlot(start_x, start_y, params.min_z),
          _shiftPlot(end_x, end_y, params.min_z)
        ]); // from the blood stain to the edge of the chart in the Y-Z plane
        exclude_edges.add([
          exclude_count,
          exclude_count + 1
        ]); // line from the stain the the endpoint
        exclude_count += 2;
      }

      ////   $po_nodes       .= shiftPlot(0.0,$start_y,$start_z) . shiftPlot($height[$i],$end_y,$end_z); // from the stain to the estimated impact point for this specific string
      //
      //  Now we build up the 3D strings.
      //
      //  They are drawn from the Y-Z plane that holds the stains (X=0) to the spot where the AO was calculated.
      //  The AO is found by using the average_height (params.convergenceX) value and the equations for each line.
      //
      // - 26 june 2018 change -
      //
      //   change the graph to draw the 3D line until it crosses the X-Y plane (Z=0) for each of these lines.
      //   That way we aren't plotting to the line containing the AO but showing the actual "strings" from each
      //   stain.
      //
      //   For each parametric equation, find a t value which gives us Z=0. We then use that t value to calculate
      //   corresponding X and Y values.
      //
      // old line     $po_nodes       .= shiftPlot(0.0,params.sample.bloodStains[i].y,params.sample.bloodStains[i].z) . shiftPlot(params.convergenceX,params.convergenceY,$height[$i]); // from the stain to the estimated impact point for this specific string
      //              outputs.add(Output("po_nodes = shiftPlot(0.0,params.sample.bloodStains[i].y,params.sample.bloodStains[i].z) . shiftPlot($height[$i],params.convergenceY,params.convergenceZ);");

      if (params.detailed) {
        outputs.add(Output(
            "3D strings: min_z=params.min_z p1z[${i + 1}]=params.sample.bloodStains[i].z Delta_z[${i + 1}]=${params.sample.bloodStains[i].deltaZ}\n"));
      }
// note:params.sample.bloodStains[i].z is NEVER zero
      var temp_t = (params.min_z - params.sample.bloodStains[i].z) /
          params.sample.bloodStains[i]
              .deltaZ; 
      var zp = params.min_z;
      // note:params.sample.bloodStains[i].x is always zero!
      var xp = params.sample.bloodStains[i].x +
          (temp_t *
              params.sample.bloodStains[i]
                  .deltaX); 
      var yp = params.sample.bloodStains[i].y +
          (temp_t * params.sample.bloodStains[i].deltaY);

      if (xp < 0.0) {
        if (params.detailed) {
          outputs
              .add(Output("Using Z generated a negative X value, using Y\n"));
        }
        // note:params.sample.bloodStains[i].z is NEVER zero
        temp_t = (params.min_y - params.sample.bloodStains[i].y) /
            params.sample.bloodStains[i]
                .deltaY; 
        zp = params.sample.bloodStains[i].z +
            (temp_t * params.sample.bloodStains[i].deltaZ);
// note:params.sample.bloodStains[i].x is always zero!
        xp = params.sample.bloodStains[i].x +
            (temp_t *
                params.sample.bloodStains[i]
                    .deltaX); 
        yp = params.min_y;
      }

      if (params.detailed) {
        outputs.add(Output("3D strings:<P>temp_t=$temp_t xp=$xp yp=$yp\n"));
      }

      if (params.sample.bloodStains[i].include) {
        if (params.detailed) {
          outputs.add(Output(
              "3D included: po_nodes = shiftPlot(0.0,${params.sample.bloodStains[i].y},${params.sample.bloodStains[i].z}) . shiftPlot($xp,$yp,$zp);"));
        }
        po_nodes.addAll([
          _shiftPlot(0.0, params.sample.bloodStains[i].y,
              params.sample.bloodStains[i].z),
          _shiftPlot(xp, yp, zp)
        ]); // from the stain to the estimated impact point for this specific string
        po_edges.add([
          po_edge_count,
          po_edge_count + 1
        ]); // from the stain to the estimated PO.
        po_edge_count += 2;
      } else {
        if (params.detailed) {
          outputs.add(Output(
              "3D NOT included: po_nodes = shiftPlot(0.0,${params.sample.bloodStains[i].y},${params.sample.bloodStains[i].z}) . shiftPlot($xp,$yp,${params.min_z});"));
        }
        excl_po_nodes.addAll([
          _shiftPlot(0.0, params.sample.bloodStains[i].y,
              params.sample.bloodStains[i].z),
          _shiftPlot(xp, yp, params.min_z)
        ]); // from the stain to the estimated impact point for this specific string
        excl_po_edges.add([
          excl_po_edge_count,
          excl_po_edge_count + 1
        ]); // from the stain to the estimated PO.
        excl_po_edge_count += 2;
      }

      //
      //  duplicate labels to the end of the lines too...  26-june-2018
      //
      //    $end_3Dlabel_coord    .= shiftPlot($xp,$yp+0.6,params.min_z+0.6);   // put the stain number next to the stain

      end_3Dlabel_coord.add(_shiftPlot(
          xp, yp + 0.6, zp + 0.6)); // put the stain number next to the stain
      end_3Dlabel.add("${i + 1}");

      if (params.detailed) {
        outputs.add(Output("--- end of stain ${i + 1} --\n"));
      }
    } //   next $i: end for to count valid entries to save.

    // ----  js version ------
    //
    //  The POI variables represent the 2D point of convergence of the lines. We draw a line parallel to the Z axis.
    //  where the X value was determined by the intersection of all lines. We then use the average Y and Z values
    //  and draw a line perpendicular to the YZ plane. All of the lines from each stain should touch this vertical.
    //  when we average the height each line makes with this X value, we find the Z coordinate of the AO.
    //
    //
    //
    //    $poi      .= shiftPlot(0,params.convergenceY,params.convergenceZ);
    //    $poi_line .= shiftPlot(0,params.convergenceY,params.convergenceZ) . shiftPlot(params.max_height ,params.convergenceY,params.convergenceZ);

    poi.add(_shiftPlot(params.convergenceX, params.convergenceY, params.min_z));
    poi_line.addAll([
      _shiftPlot(params.convergenceX, params.convergenceY, params.min_z),
      _shiftPlot(params.convergenceX, params.convergenceY, params.max_height)
    ]);
    if (params.detailed) {
      outputs.add(Output(
          "poi      .= shiftPlot(${params.convergenceX},${params.convergenceY},${params.min_z});"));
    }
    if (params.detailed) {
      outputs.add(Output(
          "poi_line .= shiftPlot(${params.convergenceX},${params.convergenceY},${params.min_z}) + shiftPlot(${params.convergenceX},${params.convergenceY},${params.max_height});"));
    }

    //my params.min_x =  0.0;
    //my params.max_x =  params.max_height;

    x_low = params.convergenceX -
        params.cpXStd; // this is the box around the calculated AO showing
    x_high = params.convergenceX +
        params.cpXStd; // the size fo the error in each direction.
    y_low = params.convergenceY - params.cpYStd;
    y_high = params.convergenceY + params.cpYStd;
    z_low = params.convergenceZ - params.cpZStd;
    z_high = params.convergenceZ + params.cpZStd;

    if (params.detailed) {
      outputs.add(Output("AO error Limits:"));
    }
    if (params.detailed) {
      outputs.add(Output(
          " $x_low < X < $x_high,   ${params.convergenceX} +/- ${params.cpXStd}"));
    }
    if (params.detailed) {
      outputs.add(Output(
          " $y_low < Y < $y_high,   ${params.convergenceY} +/- ${params.cpYStd}"));
    }
    if (params.detailed) {
      outputs.add(Output(
          " $z_low < Z < $z_high,   ${params.convergenceZ} +/- ${params.cpZStd}"));
    }
    if (params.detailed) {
      outputs.add(Output("---------------------------"));
    }

    //
    // Here we draw a box around the determined AO. The width, height and depth of the box depends on the relative
    // errors in our measurements.
    //
    //
    //
    poi_err.addAll([
      _shiftPlot(x_low, y_low, z_low),
      _shiftPlot(x_high, y_low, z_low),
      _shiftPlot(x_high, y_high, z_low),
      _shiftPlot(x_low, y_high, z_low)
    ]);

    poi_err.addAll([
      _shiftPlot(x_low, y_low, z_high),
      _shiftPlot(x_high, y_low, z_high),
      _shiftPlot(x_high, y_high, z_high),
      _shiftPlot(x_low, y_high, z_high)
    ]);
    poi_err_e = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0],
      [0, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 4],
      [7, 3],
      [6, 2],
      [5, 1]
    ];

    if (params.detailed) {
      outputs.add(Output(
          "avg_po   .= shiftPlot(${params.convergenceZ},${params.convergenceY},${params.convergenceZ});"));
    }
    avg_po.add(_shiftPlot(params.convergenceX, params.convergenceY,
        params.convergenceZ)); //    convergence_stddev

    // -----------------------

    // params.min_x =  0.0;
    // params.max_x =  params.max_height;

    //
    //
    //  Tick marks for the axes

    if (params.detailed) {
      outputs.add(Output("Chart dimensions:"));
      outputs.add(Output(
          "Height(x) Min=${params.min_height}, Max=${params.max_height}"));
      outputs.add(Output("Y Min=${params.min_y}, Max=${params.max_y}"));
      outputs.add(Output("Z Min=${params.min_z}, Max=${params.max_z}"));
    }

    double x_range = params.max_x - params.min_x;
    double y_range = params.max_y - params.min_y;
    double z_range = params.max_z - params.min_z;

    num common_range = 0;
    if (x_range > common_range) {
      common_range = x_range;
    }
    if (y_range > common_range) {
      common_range = y_range;
    }
    if (z_range > common_range) {
      common_range = z_range;
    }

    //
    //-------------- X-----------------------------
    int edge_counter = 0;
    num denominator = 25;

    while (x_range < denominator) {
      denominator = denominator * 0.5;
    }

    if (denominator == 0) {
      denominator = 1.0;
    } // this will never run right?

    // just as a fudge to get 5 ticks over the range (for now)
    int step_size = 5 * ((params.max_x - params.min_x) ~/ denominator);
    int start_point = step_size * (1 + (params.min_x ~/ step_size));

    // var last_x = start_point + common_range;
    //was 5jun2018  params.max_x )
    last_x = start_point + common_range;
    while (start_point <= last_x) {
      x_ticks.addAll([
        _shiftPlot(start_point.toDouble(), params.min_y, params.min_z),
        _shiftPlot(start_point.toDouble(), params.min_y - 1.0, params.min_z)
      ]);
      x_edges.add([edge_counter, edge_counter + 1]);
      edge_counter += 2;
      x_lbl_c.add(
          _shiftPlot(start_point.toDouble(), params.min_y - 2.3, params.min_z));
      x_lbl.add("$start_point");

      start_point += step_size;
    }

    //-------------- Y -----------------------------
    edge_counter = 0;
    denominator = 25;

    while (y_range < denominator) {
      denominator = denominator * 0.5;
    }

    if (denominator == 0) {
      denominator = 1.0;
    } // this wil never run right?

    // just as a fudge to get 5 ticks over the range (for now)
    step_size = 5 * ((params.max_y - params.min_y) ~/ denominator);
    start_point =
        step_size * (1 + (params.min_y ~/ step_size)); //-->cast to int

    // var last_y = start_point + common_range;
    last_y = start_point + common_range;

    while (start_point <= last_y) {
      //  was 5jun2018   params.max_y )
      y_ticks.addAll([
        _shiftPlot(params.min_x, start_point.toDouble(), params.min_z),
        _shiftPlot(params.min_x, start_point.toDouble(), params.min_z - 2.0)
      ]);
      y_edges.add([edge_counter, edge_counter + 1]);
      edge_counter += 2;
      y_lbl_c.add(
          _shiftPlot(params.min_x, start_point.toDouble(), params.min_z - 4));
      y_lbl.add("$start_point");

      start_point += step_size;
    }
    //-------------- Z -----------------------------
    edge_counter = 0;

    denominator = 25;

    while (z_range < denominator) {
      denominator = denominator * 0.5;
    }

    if (denominator == 0) {
      denominator = 1.0;
    } // this wil never run right?

    // just as a fudge to get 5 ticks over the range (for now)
    step_size = 5 * ((params.max_z - params.min_z) ~/ denominator);
    start_point = step_size * (1 + (params.min_z ~/ step_size)); //cast to int

    // var last_z = start_point + common_range;
    last_z = start_point + common_range;

    // was 5jun2018   params.max_z )
    while (start_point <= last_z) {
      z_ticks.addAll([
        _shiftPlot(params.min_x, params.min_y, start_point.toDouble()),
        _shiftPlot(params.min_x, params.min_y - 2.0, start_point.toDouble())
      ]);
      z_edges.add([edge_counter, edge_counter + 1]);
      edge_counter += 2;
      z_lbl_c.add(
          _shiftPlot(params.min_x, params.min_y - 6, start_point.toDouble()));
      z_lbl.add("$start_point");

      start_point += step_size;
    }

    return outputs;
  } // endsub plot_2d_chart ----------------------------------------------------------------------------------------------
}
