import 'dart:math';

import 'package:intl/intl.dart';
import 'package:vector_math/vector_math.dart';

import '../models/output.dart';
import '../models/results_param.dart';
import 'chart_info.dart';
import 'db_service.dart';

class DataProcessor {
  ResultParameters params;
  ChartInfo chartInfo;

  DataProcessor(this.params) :  chartInfo = ChartInfo(params);
  

  Future<List<Output>> process() async {
    List<Output> outputs = [];

    outputs.add(Output(
        'The columns of the results table reflect input data. The '
        '"C.Dist" column represents the distance of each blood stain from the '
        'calculated point of intersection of all strings.'));
    outputs.add(
        Output('The "Height" column represents the impact height, for each '
            'stain, as a distance above the X-Y plane.'));

    if (params.detailed) {
      outputs.add(Output('Validate Stains', type:Output.bold));
    }
    validateStains();

    if (params.detailed) {
      outputs.add(Output('Make 3D Lines', type:Output.bold));
    }
    outputs.addAll(await make3DLines());

    if (params.detailed) {
      outputs.add(Output('Find X-Y Intersections', type:Output.bold));
    }
    outputs.addAll(await findXYPlaneIntersections());

    if (params.intersections.isEmpty) {
      outputs.add(Output(
          "The dataset provided does not contain a sufficient number of stains from opposing sides to allow for an analysis.",
          txtColor: Output.red));
      outputs.add(Output(
          "Please submit a dataset that has stains on both the left and right hand sides of the pattern."));
    } else {
      if (params.detailed) {
        outputs.add(Output('Convergence Point', type:Output.bold));
      }
      outputs.addAll(await convergencePoint());

      if (params.detailed) {
        outputs.add(Output('Closest 2D', type:Output.bold));
      }
      outputs.addAll(await closest2D());

      if (params.detailed) {
        outputs.add(Output('AO Z value', type:Output.bold));
      }
      outputs.addAll(await calcAOZValue());

      if (params.detailed) {
        outputs.add(Output(''));
      }
      outputs.addAll(await displayResults());
    }

    outputs.addAll(await chartInfo.plot_2d_chart());

    return outputs;
  }

  validateStains() async {
//
// If the y and z coordinates are given, assume the whole row of data is valid.
//
// Count how many Stains contain valid data. Each Stain represents a single blood stain and it's "string"
//
//

    params.yNPoints = 0;
    for (int i = 0; i < params.sample.numStains; i++) {
      //    First, based on the gamma angle, decide if the stain is on the left or right quadrant of the pattern.
      //    based on zero degrees representing the vertical when gamma is measured, angles between 0 and 180 degrees are considered
      //    to be on the right hand quadrant. Between 180 and 360 degrees would find the stain on the left hand quadrant.
      //    When we calcualte the common/average point of intersection, we only use lines from different quadrants to calculate
      //    individual points of intersection between lines.
      //
      //    Special cases:
      //      Y:  for angles that are essentially zero degrees, we will label them as Y as the Y coordinates of all
      //          points will be the same. We then want to find the intersection of these lines with both the
      //          "R" and "L" lines. The vertical "Y" lines are tought to give a much more accurate determination of
      //          the Y coordinate for the AO.
      //
      //      Z:  For gamma angles of 90 degrees and "z" for those at 270 degrees. For these stains, the Z coordinate
      //          for their strings will be static/common to all points.
      // xyzzy
      //

      ///<-- TO DELETE:
      /// push(@all_stains,$i);  // a list of all of the stains (INCLuded or not)

      // for now ignore the vertical and horizontal strings. Nake sure we get the same answer as before, before adding the complexity.
      //

      if (params.sample.bloodStains[i]
          .include) //   If the user decided to include this datapoint in the calculations
      {
        if ((params.sample.bloodStains[i].gamma == 360.0) ||
            (params.sample.bloodStains[i].gamma ==
                0.0)) // remember gamma measured from the vertical these = zero degrees
        {
          params.sample.bloodStains[i].quadrant =
              "Y"; // stains are Y coordinate restricted
          params.verticalStains.add(
              i); // this array will only include valid stains from the right side
        }

        if ((params.sample.bloodStains[i].gamma > 0.0) &&
            (params.sample.bloodStains[i].gamma <
                180.0)) // remember gamma measured from the vertical
        {
          params.sample.bloodStains[i].quadrant = "R";
          params.rightStains.add(
              i); // this array will only include valid stains from the right side
        }

        if ((params.sample.bloodStains[i].gamma > 180.0) &&
            (params.sample.bloodStains[i].gamma < 360.0)) {
          params.sample.bloodStains[i].quadrant = "L";
          params.leftStains.add(
              i); // this array will only include valid stains from the left side
        }

        params.yNPoints++;
      } // if we want to include this point in the determination of the AO

//
//    move the form data into the appropriate variables.
//

      ///<-- TO DELETE:
      ///$impact_angle[$i] =  radians($alpha[$i]);  // we may change this to Fred's BETA angle as discussed in his 2001 paper.

      ///<-- TO DELETE:
      /// $gamma_angle[$i]  =  radians(params.sample.bloodStains[i].gamma);

    }
  } // end sub validate_Stains

  Future<List<Output>> make3DLines() async {
//--------------------------------------------------------------------------------------------------
//
//  From the given data P1(x,y,z)  calculate P2(x,y,z)
//
//  here we take the Y-Z coordinates and combine them with alpha and gamma to calculate the
//  coordinates of a second point for thie string/line. P1=(0,y,z) and we need to calcuate
//  P2's x,y and z coordinates. For this we use spherical polar coordinates and convert them to
//  cartesian coordinates. We'll be using the formuals found here:
//
//   http://mathworld.wolfram.com/SphericalCoordinates.html
//
//   Notice in the diagram presented on this web site, their angle Phi measures the angle from the vertical.
//   This corresponds to our measurement of the angle we call Gamma. Also In the diagram the angle
//   Theta is the angle made with respect to the X axis. In our data, Alpha represents the angle made
//   with respect to the Y-Z plane so our Alpha is the complimentary angle to Theta. Hence we need
//   to subtract our Alpha value from 90 degreed to get a proper angle.
//
//   therefore:
//              P2(x) = r cos(90-Aplha) sin(Gamma)
//              P2(y) = r sin(90-Alpha) sin(Gamma)
//              P2(z) = r cos(Gamma)
//
//    we take the Z value of the datapoint for our value of r. It should be the largest value
//    we get in our dataset (height from the floor).
//

    List<Output> outputs = [];

    for (int i = 0; i < params.sample.numStains; i++) {
      if (params.detailed) {
        outputs.add(Output(
            'Calculating additional points on the ${i + 1} line\n'
            'This stain lies in the ${params.sample.bloodStains[i].quadrant} '
            'quadrant (Y==vertical)\n'
            'Gamma[${i + 1}]=${params.sample.bloodStains[i].gamma}, '
            'alpha[${i + 1}]=${params.sample.bloodStains[i].alphaAsRad}'));
      }

      double r =
          4.0; // to match spreadsheet for now .... then -> params.sample.bloodStains[i].z;                              // use the z coord as the radius
      double yAdj = 1.0;
      double zAdj = 1.0;

      double gamma2 = 0.0;
      if ((450.0 - params.sample.bloodStains[i].gamma) > 360.0) {
        gamma2 = (90.0 - params.sample.bloodStains[i].gamma);
      } else {
        gamma2 = (450.0 - params.sample.bloodStains[i].gamma);
      }

      if (params.detailed) {
        outputs.add(Output(
            'Original gamma=${params.sample.bloodStains[i].gamma}, gamma2=$gamma2'));
      }

      if (params.sample.bloodStains[i].quadrant ==
          "Y") // vertical line. All stains above the horizontal ==> all Z values less than stain Z value.
      {
        yAdj = -1.0;
        zAdj = -1.0;
      } else {
        if ((params.sample.bloodStains[i].gamma >= 0.0) &&
            (params.sample.bloodStains[i].gamma < 90.0)) {
          yAdj = -1.0;
          zAdj = -1.0;
        }
        if ((params.sample.bloodStains[i].gamma >= 90.0) &&
            (params.sample.bloodStains[i].gamma < 180.0)) {
          yAdj = -1.0;
          zAdj = 1.0;
        }
        if ((params.sample.bloodStains[i].gamma >= 180.0) &&
            (params.sample.bloodStains[i].gamma < 270.0)) {
          yAdj = 1.0;
          zAdj = 1.0;
        }
        if ((params.sample.bloodStains[i].gamma >= 270.0) &&
            (params.sample.bloodStains[i].gamma < 360.0)) {
          yAdj = 1.0;
          zAdj = -1.0;
        }
      }

      if (params.detailed) {
        outputs.add(Output("yAdj=$yAdj zAdj=$zAdj"));
      }
//
//   Fred's algorithm uses an angle called Beta (Fred 2001 page 3). The original Sherlock code
//   simply used Alpha (impact angle) for calculating the AO's X coordinate. There is a slight
//   discrepancy between this value and Fred's as gamma increases. We now offer Fred's Beta
//   angle as an option.
//
      double aOrB = params.sample.bloodStains[i].alphaAsRad;

//     if( $beta_choice eq "Beta" )
//      {
//        $aOrB = atan( tan($impact_angle[$i]) / cos(params.sample.bloodStains[i].gamma) );
////        outputs.add(Output("<B>using Beta: Impact angle:$impact_angle[$i]  Beta=$aOrB</b><BR>";
//      }

      var sinAlpha = sin(aOrB);
      var cosAlpha = cos(aOrB);

      if (cosAlpha == 0.0) {
        cosAlpha = 0.00000000001;
        if (params.detailed) {
          outputs.add(Output('cosAlpha was zero', type: Output.bold));
        }
      } // prevent the dreaded div by zero!

      if (params.sample.bloodStains[i].quadrant ==
          "Y") // vertical line. All stains above the horizontal ==> all Z values less than stain Z value.
      {
        params.sample.bloodStains[i].z2 = params.sample.bloodStains[i].z +
            (zAdj * r * cosAlpha); // generate new Z values for the line
        params.sample.bloodStains[i].z3 =
            params.sample.bloodStains[i].z + (zAdj * (2.3 * r) * cosAlpha);

        params.sample.bloodStains[i].x2 =
            r * sinAlpha; // The X component is always positive.
        params.sample.bloodStains[i].x3 = (2.3 * r) * sinAlpha;

        params.sample.bloodStains[i].y2 = params.sample.bloodStains[i]
            .y; // line is vertical so all Y coordinates are the same.
        params.sample.bloodStains[i].y3 = params.sample.bloodStains[i]
            .y; // line is vertical so all Y coordinates are the same.

        params.sample.bloodStains[i].deltaX =
            params.sample.bloodStains[i].x3 - params.sample.bloodStains[i].x2;
        params.sample.bloodStains[i].deltaY = 0;
        params.sample.bloodStains[i].deltaZ =
            params.sample.bloodStains[i].z3 - params.sample.bloodStains[i].z2;
      } else {
        var sinGamma2 = (sin(radians(gamma2))).abs();
        var cosGamma2 = (cos(radians(gamma2))).abs();

        if (params.detailed) {
          outputs.add(Output('yAdj=$yAdj  zAdj=$zAdj gamma2=$gamma2\n'
              'Cos(Alpha)=$cosAlpha   sin(alpha)=$sinAlpha\n'
              'cos(gamma2)=$cosGamma2  sin(gamma2)=$sinGamma2\n'));
        }

        params.sample.bloodStains[i].z2 =
            params.sample.bloodStains[i].z + (zAdj * r * sinGamma2);
        params.sample.bloodStains[i].y2 =
            params.sample.bloodStains[i].y + (yAdj * r * cosGamma2);

        var a1 =
            (params.sample.bloodStains[i].y2 - params.sample.bloodStains[i].y);
        var b1 =
            (params.sample.bloodStains[i].z2 - params.sample.bloodStains[i].z);
        var c1 = sqrt((a1 * a1) + (b1 * b1));
        var d1 = c1 / cosAlpha;

        var r_xy = d1;
//     var r_xy = sqrt( (params.sample.bloodStains[i].y2-params.sample.bloodStains[i].y)^2 + (params.sample.bloodStains[i].z2-params.sample.bloodStains[i].z)^2 ) / cosAlpha;
        params.sample.bloodStains[i].x2 =
            params.sample.bloodStains[i].x + (r_xy * sinAlpha);

        if (params.detailed) {
          outputs.add(Output(
              "p2z[${i+1}]=${params.sample.bloodStains[i].z2} = ${params.sample.bloodStains[i].z} + ( $zAdj * $r * $sinGamma2)\n"
              "p2y[${i+1}]=${params.sample.bloodStains[i].y2} = ${params.sample.bloodStains[i].y} + ( $yAdj * $r * $cosGamma2)\n"
              "r_xy = $r_xy = sqrt((${params.sample.bloodStains[i].y2}-${params.sample.bloodStains[i].y})^2 + (${params.sample.bloodStains[i].z2}-${params.sample.bloodStains[i].z})^2 ) / cosAlpha;\n"
              "p2x[${i+1}] = ${params.sample.bloodStains[i].x2}  = ${params.sample.bloodStains[i].x} + ($r_xy * $sinAlpha )"));
        }
        if (params.detailed) {
          outputs.add(Output(
              "P2 => x = ${params.sample.bloodStains[i].x2}  y=${params.sample.bloodStains[i].y2}  z=${params.sample.bloodStains[i].z2}"));
        }
//
//    We can't have an x-coordinate value of zero when we calculate the x-y intersection point.
//    Since all params.sample.bloodStains[i].x are zero by definition (blood stains are in the y-z plane), then we need
//    another datapoint along the line from which to calculate DeltaX and eventually a t value
//    for the parametric equation of the line.
//
        var r2 = 2.3 *
            r; //   * params.sample.bloodStains[i].z;  //    rand(params.sample.bloodStains[i].z);

        params.sample.bloodStains[i].y3 =
            params.sample.bloodStains[i].y + (yAdj * r2 * cosGamma2);
        params.sample.bloodStains[i].z3 =
            params.sample.bloodStains[i].z + (zAdj * r2 * sinGamma2);

        var a =
            (params.sample.bloodStains[i].y3 - params.sample.bloodStains[i].y);
        var b =
            (params.sample.bloodStains[i].z3 - params.sample.bloodStains[i].z);
        var c = sqrt((a * a) + (b * b));
        var d = c / cosAlpha;

        r_xy =
            d; //    no idea why this generates a 15 digit number if I use the next two lines???
//
// sqrt( (params.sample.bloodStains[i].y3-params.sample.bloodStains[i].y)^2 + (params.sample.bloodStains[i].z3-params.sample.bloodStains[i].z)^2 ) / cosAlpha;
// no idea why this generates a 15 digit number?!?      r_xy    = sqrt( (params.sample.bloodStains[i].y3-params.sample.bloodStains[i].y)^2 + (params.sample.bloodStains[i].z3-params.sample.bloodStains[i].z)^2 ) / cosAlpha;

        params.sample.bloodStains[i].x3 =
            params.sample.bloodStains[i].x + (r_xy * sinAlpha);
        params.sample.bloodStains[i].deltaX = params.sample.bloodStains[i].x3 -
            params.sample.bloodStains[i]
                .x2; // since r2 is always > r this keeps the Deltas +ve
        params.sample.bloodStains[i].deltaY =
            params.sample.bloodStains[i].y3 - params.sample.bloodStains[i].y2;
        params.sample.bloodStains[i].deltaZ =
            params.sample.bloodStains[i].z3 - params.sample.bloodStains[i].z2;

        if (params.detailed) {
          outputs.add(Output(
              "a=$a (${params.sample.bloodStains[i].y3}-${params.sample.bloodStains[i].y})<P>  b=$b(${params.sample.bloodStains[i].z3}-${params.sample.bloodStains[i].z})<P> c=$c   d=$d\n"
              "r_xy=$r_xy    = sqrt( (${params.sample.bloodStains[i].y3}-${params.sample.bloodStains[i].y})^2 + (${params.sample.bloodStains[i].z3}-${params.sample.bloodStains[i].z})^2 ) / cosAlpha\n"
              "p3x=${params.sample.bloodStains[i].x3} = ${params.sample.bloodStains[i].x} + ( $r_xy * $sinAlpha )\n"
              "P3 => x=${params.sample.bloodStains[i].x3}  y=${params.sample.bloodStains[i].y3}  z=${params.sample.bloodStains[i].z3}\n"
              "DeltaX[${i+1}]=${params.sample.bloodStains[i].deltaX}  = ${params.sample.bloodStains[i].x3} - ${params.sample.bloodStains[i].x2}\n"
              "DeltaY[${i+1}]=${params.sample.bloodStains[i].deltaY}  = ${params.sample.bloodStains[i].y3} - ${params.sample.bloodStains[i].y2}\n"
              "DeltaZ[${i+1}]=${params.sample.bloodStains[i].deltaZ}  = ${params.sample.bloodStains[i].z3} - ${params.sample.bloodStains[i].z2}\n"));
        }
      } // if the point is in the Y quadrant (i.e. the line is vertical)

    } // for all points on the input sheet (even the no-include lines)

    String content = '';
    String filename = params.sample.filename!.replaceAll('.csv', '');
    filename += '_linepoints.gp';

    var ctr = 1;
    for (int i = 0; i < params.sample.numStains; i++) {
      content +=
          "${params.sample.bloodStains[i].x},${params.sample.bloodStains[i].y},${params.sample.bloodStains[i].z},$ctr,S,colour$ctr,$ctr,\n";
      content +=
          "${params.sample.bloodStains[i].x2},${params.sample.bloodStains[i].y2},${params.sample.bloodStains[i].z2},$ctr,S,colour$ctr,$ctr,\n";
      content +=
          "${params.sample.bloodStains[i].x3},${params.sample.bloodStains[i].y3},${params.sample.bloodStains[i].z3},$ctr,S,colour$ctr,$ctr,\n";
      ctr++;
    }
    await DBService.saveToFile(filename, content);

    return outputs;
  } // end sub make_3d_lines

  Future<List<Output>> findXYPlaneIntersections() async {
//
//    find the point of intersection for all pairs of lines. They should all converge in a single point.
//    Because of measurement errors for the coordinates and angles, this will rarely occur mathematically.
//
//    We therefore find all of the intersection points for all pairs of lines. We will then find the geometric
//    centre for all of the points. Most of the points of intersection should still lie closely together. How
//    closely depends on measurement error.
//
//  First find all the points of intersection:
//
    List<Output> outputs = [];

    if (params.detailed) {
      outputs.add(Output("Finding intersection points between lines"));
    }
//
// Now that we have left_stains and right_stains as arrays, we can use foreach to loop through the valid stains more easily.
// Let's make the left stains $i and the right ones $j

    for (int i in params.leftStains) {
      for (int j in params.rightStains) {
        if (params.detailed) {
          outputs.add(Output(
              "Finding the intersection of lines ${i+1} and $j in the X-Y plane",
              type: Output.title));
        }
        List<Output> auxRes = await intersect(i, j);
        outputs.addAll(auxRes);
      } // for all of the lines from the right hand stains
    } // for all of the left quadrant stains

//
//  now we need to check any vertical lines against both right and left quadrant stains
//
    for (int i in params.verticalStains) {
      for (int j in params.leftStains) {
        if (params.detailed) {
          outputs.add(Output(
              "Finding the intersection of the vertical line ${i+1} and line $j in the X-Y plane\n",
              type: Output.title));
        }
        List<Output> auxRes = await yIntersect(i, j);
        outputs.addAll(auxRes);
      } // for all of the lines from the right hand stains

      for (int j in params.rightStains) {
        if (params.detailed) {
          outputs.add(Output(
              "Finding the intersection of the vertical line ${i+1} and line $j in the X-Y plane\n",
              type: Output.title));
        }
        List<Output> auxRes = await yIntersect(i, j);
        outputs.addAll(auxRes);
      } // for all of the lines from the right hand stains

    } // for all of the vertical stains
    return outputs;
  } // end sub findXYPlaneIntersections

//-----------------------------------------------------------------------------------------------------------------------
//
//  Given the parametric data for two lines, the following routine (intersect), calculates where
//  in the X-Y plane the lines intersect.
//
  Future<List<Output>> intersect(int line1, int line2) async {
    List<Output> outputs = [];

    if (params.detailed) {
      outputs.add(Output("Lines $line1 and $line2:"));
      outputs.add(Output(
          "Line $line1: p1=${params.sample.bloodStains[line1].x.toStringAsFixed(2)},${params.sample.bloodStains[line1].y.toStringAsFixed(2)},${params.sample.bloodStains[line1].z.toStringAsFixed(2)} "
          "Line $line1: p2=${params.sample.bloodStains[line1].x2.toStringAsFixed(2)},${params.sample.bloodStains[line1].y2.toStringAsFixed(2)},${params.sample.bloodStains[line1].z2.toStringAsFixed(2)} "
          "Line $line1: p3=${params.sample.bloodStains[line1].x3.toStringAsFixed(2)},${params.sample.bloodStains[line1].y3.toStringAsFixed(2)},${params.sample.bloodStains[line1].z3.toStringAsFixed(2)} "));

      outputs.add(Output(
          "Line $line2: p1=${params.sample.bloodStains[line2].x.toStringAsFixed(2)},${params.sample.bloodStains[line2].y.toStringAsFixed(2)},${params.sample.bloodStains[line2].z.toStringAsFixed(2)} "
          "Line $line2: p2=${params.sample.bloodStains[line2].x2.toStringAsFixed(2)},${params.sample.bloodStains[line2].y2.toStringAsFixed(2)},${params.sample.bloodStains[line2].z2.toStringAsFixed(2)} "
          "Line $line2: p3=${params.sample.bloodStains[line2].x3.toStringAsFixed(2)},${params.sample.bloodStains[line2].y3.toStringAsFixed(2)},${params.sample.bloodStains[line2].z3.toStringAsFixed(2)} "));
    }

//
//
//  fudge the data to avoid the possibility of a divide by zero.
//
//

    if (params.sample.bloodStains[line2].deltaX == 0) {
      params.sample.bloodStains[line2].deltaX = params.fakeZero;
      if (params.detailed) {
        outputs.add(Output("DeltaX[$line2] was zero"));
      }
    }
    if (params.sample.bloodStains[line1].deltaX == 0) {
      params.sample.bloodStains[line1].deltaX = params.fakeZero;
      if (params.detailed) {
        outputs.add(Output("DeltaX[$line1] was zero"));
      }
    }
    if (params.sample.bloodStains[line2].deltaY == 0) {
      params.sample.bloodStains[line2].deltaY = params.fakeZero;
      if (params.detailed) {
        outputs.add(Output("DeltaY[$line2] was zero"));
      }
    }
    if (params.sample.bloodStains[line1].deltaY == 0) {
      params.sample.bloodStains[line1].deltaY = params.fakeZero;
      if (params.detailed) {
        outputs.add(Output("DeltaY[$line1] was zero"));
      }
    }
//
// Calc the t value for the parametric equation for line 2 which gives us the point of intersection.
// see the document on "The math of Sherlock"
//
//  NOTICE: We ignore the Z coordinates for the point of intersection. We will calculate Z based
//          on the Alpha angles later.
//

    if (params.detailed) {
      outputs.add(Output(
          "numerator = (${params.sample.bloodStains[line1].deltaY}*(${params.sample.bloodStains[line2].x2}-${params.sample.bloodStains[line1].x2})) - (${params.sample.bloodStains[line1].deltaX}*(${params.sample.bloodStains[line2].y2}-${params.sample.bloodStains[line1].y2}));"));
    }
    if (params.detailed) {
      outputs.add(Output(
          "denom     = (${params.sample.bloodStains[line2].deltaY}*${params.sample.bloodStains[line1].deltaX}) - (${params.sample.bloodStains[line2].deltaX}*${params.sample.bloodStains[line1].deltaY});"));
    }

//   var numerator = (params.sample.bloodStains[line1].deltaX*(params.sample.bloodStains[line2].y-params.sample.bloodStains[line1].y))/(params.sample.bloodStains[line1].deltaY*(params.sample.bloodStains[line2].x-params.sample.bloodStains[line1].x));
//   var denom     = (params.sample.bloodStains[line2].deltaX*params.sample.bloodStains[line1].deltaY) - (params.sample.bloodStains[line2].deltaY*params.sample.bloodStains[line1].deltaX);

    var numerator = (params.sample.bloodStains[line1].deltaY *
            (params.sample.bloodStains[line2].x2 -
                params.sample.bloodStains[line1].x2)) -
        (params.sample.bloodStains[line1].deltaX *
            (params.sample.bloodStains[line2].y2 -
                params.sample.bloodStains[line1].y2));
    var denom = (params.sample.bloodStains[line2].deltaY *
            params.sample.bloodStains[line1].deltaX) -
        (params.sample.bloodStains[line2].deltaX *
            params.sample.bloodStains[line1].deltaY);

    if (params.detailed) {
      outputs.add(Output("numerator/denom = $numerator/$denom"));
    }

    if (denom.abs() >
        1.0e-4) // fudge to make sure !=0 but too small is just as bad
    {
      var t = numerator / denom;
      var intX = params.sample.bloodStains[line2].x2 +
          (t * params.sample.bloodStains[line2].deltaX);
      var intY = params.sample.bloodStains[line2].y2 +
          (t * params.sample.bloodStains[line2].deltaY);
      params.intersections['${line1 - line2}'] = "$intX, $intY";
      if (params.detailed) {
        outputs.add(Output(
            "intX = ${params.sample.bloodStains[line2].x2} + ($t * ${params.sample.bloodStains[line2].deltaX})"));
      }
      if (params.detailed) {
        outputs.add(Output(
            "intY = ${params.sample.bloodStains[line2].y2} + ($t * ${params.sample.bloodStains[line2].deltaY})"));
      }
      if (params.detailed) {
        outputs.add(Output(
            "t=$t<BR>Lines $line1 and $line2 intersect in the X-Y plane at the point: ($intX,$intY)<BR>\n"));
      }
    } else {
      if (params.detailed) {
        outputs.add(Output(
            "Lines $line1 and $line2 do NOT intersect Denominator for t calulation is zero<BR>\n"));
      }
    }
    return outputs;
  } // endsub intersect

//--------------------------------------------------------------------------------------------------------------------------
//
// This subroutines finds the intersection of any left/right quadrant line with a vertical line.
// It assumes tha tthe first line index passed is the vertical line. The second index is either a "R" or "L" quadrant line.
//line1 - // this is the vertical line's index. All Y coordinatres for the intersection must match this value.
  Future<List<Output>> yIntersect(int line1, int line2) async {
    List<Output> outputs = [];

//
//  Find the t value which satisfies y(line1) = y1(line2) + (t * deltay(line2))
//
//
    if (params.detailed) {
      outputs.add(Output(
          "Line $line1 is vertical - Line 2: ${params.sample.bloodStains[line2].quadrant}  "));
    }

    var t = (params.sample.bloodStains[line1].y -
            params.sample.bloodStains[line2].y) /
        params.sample.bloodStains[line2].deltaY;
    var intX = params.sample.bloodStains[line2].x2 +
        (t * params.sample.bloodStains[line2].deltaX);
    params.intersections["${line1 - line2}"] =
        "$intX,${params.sample.bloodStains[line1].y}";
    if (params.detailed) {
      outputs.add(Output(
          "intersections[${line1 - line2}] = $intX,${params.sample.bloodStains[line1].y}"));
    }
    return outputs;
  } // endsub yIntersect

//
//-----------------------------------------------------------------------------------------------------------------------
//
//  The convergence_point routine generates a point in the X-Y plane which is an average of the points
//  of intersection for all of the "strings".  Basically, it averages out the X and Y coordinates to find
//  a central point which can then be used to calculate heights which will lead to the calculation of the
//  Point-of-Origin.
//
//
//
  Future<List<Output>> convergencePoint() async {
    var keys = [];
    var nPoints = 0;
    var x, y;
    var test_stddev; // For each of lines to be removed (if any) calculate the centre and std.dev. Smallest std.dev wins.
    var test_x; // Coordinates (x,y) of the centroid caclulated without line___
    var test_y;
    var bad_stddev; // For each of lines to be removed (if any) calculate the centre and std.dev. Smallest std.dev wins.
    var bad_x; // Coordinates (x,y) of the centroid caclulated without line___
    var bad_y;
    var distance;
    var sumX = 0.0;
    var sumY = 0.0;
    var centre_x = 0.0;
    var centre_y = 0.0;

    List<Output> outputs = [];

    if (params.detailed) {
      outputs
          .add(Output("The weighted point of convergence for all lines is:"));
    }

//
//  first run the calc for centre using all points.
//
    if (params.detailed) {
      outputs.add(Output("in convergence_point"));
    }

    nPoints = 0;
    //List<String> iKeys = params.intersections.keys.toList();

    if (params.detailed) {
      outputs.add(Output("\tnPoints++ [key] [intersections[key]] = x  y "));
    }
    params.intersections.forEach((key, value) {
      nPoints++;
      var xy = value.split(",");
      x = double.parse(xy[0]);
      y = double.parse(xy[1]);
      sumX += x;
      sumY += y;
      if (params.detailed) {
        outputs.add(Output("\t$nPoints++ [$key] [$value] = $x  $y"));
      }
    }); // end  foreach

    params.convergenceX = sumX / nPoints;
    params.convergenceY = sumY / nPoints;
//
//  calc standard deviation
//
    distance = 0.0;
    params.cpXStd = 0.0;
    params.cpYStd = 0.0;

    params.intersections.forEach((key, value) {
      var xy = value.split(",");
      x = double.parse(xy[0]);
      y = double.parse(xy[1]);
      distance += sqrt(
          pow(params.convergenceX - x, 2) + pow(params.convergenceY - y, 2));
      params.cpXStd += sqrt(pow(params.convergenceX - x, 2));
      params.cpYStd += sqrt(pow(params.convergenceY - y, 2));
    }); // end  foreach

    params.convergenceStd = sqrt(distance / nPoints);
    params.cpXStd = sqrt(params.cpXStd / nPoints);
    params.cpYStd = sqrt(params.cpYStd / nPoints);

//---------------------------------------------------------
    outputs.add(Output("Calculated point of intersection for all strings:",
        type: Output.title));

    outputs.add(Output(
        "The centroid for the points of intersection in the X-Y plane is: ("
        "${params.convergenceX} [Std=${params.cpXStd}] "
        "${params.convergenceY} [Std=${params.cpYStd}] with a std: "
        "${params.convergenceStd}"));

    return outputs;
  } //end sub convergence_point

//===================================================================================
//
//  This routine calculates the closest distance from the point of convergence to each each line.
//  This allows for the detection or highlighting of possibly "bad" lines.
//
//   https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
//
//  since the delta_(x,y,z) are calculated between P3 and P2, we use the P3 and P2 points below.
//
  Future<List<Output>> closest2D() async {
    List<Output> outputs = [];
    if (params.detailed) {
      outputs.add(Output("in closest2D"));
    }

    double avg_dist = 0.0;

    for (var i = 0; i < params.sample.numStains; i++) {
      // check out each point - was $MAX_POINTS
      var dx = params.sample.bloodStains[i].x2 - params.sample.bloodStains[i].x;
      var dy = params.sample.bloodStains[i].y2 - params.sample.bloodStains[i].y;
      var num = ((dy * params.convergenceX) -
              (dx * params.convergenceY) +
              (params.sample.bloodStains[i].x2 *
                  params.sample.bloodStains[i].y) -
              (params.sample.bloodStains[i].y2 *
                  params.sample.bloodStains[i].x)).abs();
      var denom = sqrt((dy * dy) + (dx * dx));
      if (params.detailed) {
        outputs.add(Output("Line ${i+1}"));
        outputs.add(Output("num = abs(($dy*${params.convergenceX})-"
        "($dx*${params.convergenceY}) + (${params.sample.bloodStains[i].x2}*"
        "${params.sample.bloodStains[i].y})-(${params.sample.bloodStains[i].y2}*"
        "${params.sample.bloodStains[i].x}))"));
        outputs.add(Output("denom = sqrt(($dy*$dy) + ($dx*$dx))"));
      }

      if (denom == 0) {
        params.sample.bloodStains[i].dist2D = 0;
      } else {
        params.sample.bloodStains[i].dist2D = num / denom;
      }
      avg_dist += params.sample.bloodStains[i].dist2D;

      if (params.detailed) {
        //printf("Line [%d] through the points (%6.2f,%6.2f)-(%6.2f,%6.2f)  Distance to Conversion point= %6.2f<br>\n",$i,$P1x,$P1y,$P2x,$P2y,$dist2D[$i]);
        outputs.add(Output("line:${i+1} "
            "P1=(${params.sample.bloodStains[i].x},${params.sample.bloodStains[i].y})\n"
            "P2=(${params.sample.bloodStains[i].x2},${params.sample.bloodStains[i].y2})\n"
            "num=$num\n "
            "denom=$denom\n"
            "Distance=${params.sample.bloodStains[i].dist2D},"));
      }
    } // for each data point

    avg_dist = avg_dist / params.sample.numStains;
    if (params.detailed) {
      outputs.add(Output("Average Dist. to Conversion point= $avg_dist"));
    }

    return outputs;
  } // end of closest_2d

  Future<List<Output>> calcAOZValue() async {
//--------------------------------------------------------------------------------
//
//   We now calculate the height from the x-y plane for the z coordinate the source of the
//   splatter was located.
//
//   We have calculated a proper X coordinate from the trajectory view (x-y) plane. This average
//   of all of the lines gives us our best X coordiate guess removing gravity and air resistance effects.
//
//   We can now use the parametric equation of the line to calculate the value of "t" which gives
//   us the found X value. From that value of "t", calculate the appropriate z value. We will then
//   have all 3 coordinates. x & y from the average and z from this calcualted value.
//
//   We then combined all of the Z values for all of the lines to find the area of origin.
//
//
    double avg_z = 0.0;
    double z_stddev = 0.0;

    List<Output> outputs = [];

    String content = "";
    String filename = params.sample.filename!.replaceAll('.csv', '');
    filename += '_coordinates_metod1.csv';

    content += "Point Number, X_Coord, Y_Coord, Height, Include?,\n";

    if (params.detailed) {
      outputs.add(Output("Point Number, X_Coord, Y_Coord, Z_Coord, Include?,\n"));
    }

    for (int i = 0; i < params.sample.numStains; i++) {
      if (params.sample.bloodStains[i].include) {
        // only include what the client wants to calc average height.
        if (params.detailed) {
          outputs.add(Output("Point number: ${i+1}"));
        }
//
//   Find the t value from the parametric equation that generates this value for Y
//   for this we use the original Y values whcih generated the line.
//
        params.sample.bloodStains[i].height = 0.0;
//    my t_value = ($params.convergenceY-params.sample.bloodStains[i].y) / params.sample.bloodStains[i].deltaY;   // params.sample.bloodStains[i].deltaY is based off P3y[$i]-P2y[$i]

        double t_value = 0.0;
//   For vertical points, it is possible that delta_y[$i] is essentially zero. We can't divide by
//   zero so we therefore use the delta_x[$i] to find a value for t.
//
//   Now that we have t, plug it into the parametric equation for find the Z value of the AO.

        var y_diff = params.convergenceY - params.sample.bloodStains[i].y;

// Temp removal to see if the small delta_y issue can be resolved using X instead....
        if (params.detailed) {
          outputs.add(Output("y_diff=$y_diff"));
        }

        if (1 == 2) {
          //   was ->  abs($y_diff) > $fake_zero ) // abs(params.sample.bloodStains[i].deltaY) > $fake_zero )

          t_value = (params.convergenceY - params.sample.bloodStains[i].y) /
              params.sample.bloodStains[i]
                  .deltaY; // params.sample.bloodStains[i].deltaY is based off P3y[$i]-P2y[$i]
          if (params.detailed) {
            outputs.add(Output(
                "t_value = (${params.convergenceY}-${params.sample.bloodStains[i].y}) / ${params.sample.bloodStains[i].deltaY}"));
          }
          params.sample.bloodStains[i].height = params.sample.bloodStains[i].z +
              (t_value * params.sample.bloodStains[i].deltaZ);
        } else {
          if (params.detailed) {
            outputs.add(Output("WARNING: t calc delta_y was too small",
                txtColor: Output.red));
          }
          t_value = (params.convergenceX - params.sample.bloodStains[i].x2) /
              params.sample.bloodStains[i]
                  .deltaX; // params.sample.bloodStains[i].deltaY is based off P3y[$i]-P2y[$i]
          if (params.detailed) {
            outputs.add(Output(
                "t_value = (${params.convergenceX}-${params.sample.bloodStains[i].x2})/${params.sample.bloodStains[i].deltaX}"));
            outputs.add(Output(
                "height[$i] = ${params.sample.bloodStains[i].z2} + ( $t_value*${params.sample.bloodStains[i].deltaZ})"));
          }
          params.sample.bloodStains[i].height =
              params.sample.bloodStains[i].z2 +
                  (t_value * params.sample.bloodStains[i].deltaZ);
        }

        //use the X value to find a proper t value
        t_value = (params.convergenceX - params.sample.bloodStains[i].x2) /
            params.sample.bloodStains[i]
                .deltaX; // params.sample.bloodStains[i].deltaY is based off P3y[$i]-P2y[$i]
        params.sample.bloodStains[i].height = params.sample.bloodStains[i].z2 +
            (t_value * params.sample.bloodStains[i].deltaZ);
        //"%3d,%6.2f,%6.2f,%6.2f,%s"
        NumberFormat f = NumberFormat("###0.00", "en_US");

        String str =
            "${i.toString().padLeft(3, " ")},${f.format(params.convergenceX)},"
            "${f.format(params.convergenceY)},"
            "${f.format(params.sample.bloodStains[i].height)},"
            "${params.sample.bloodStains[i].getInclude}\n";

        content += str;

        if (params.detailed) {
          outputs.add(Output(str));
        }

        // Calculate the distance from the original stain.
        var dx = params.convergenceX - params.sample.bloodStains[i].x;
        var dy = params.convergenceY - params.sample.bloodStains[i].y;
        var dz = params.sample.bloodStains[i].height -
            params.sample.bloodStains[i].z;
        params.sample.bloodStains[i].distToConvergence =
            sqrt((dx * dx) + (dy * dy) + (dz * dz));
        if (params.detailed) {
          outputs.add(Output(
              "from convergence point:<BR>delta_x=$dx delta_y=$dy delta_z=$dz distance=${params.sample.bloodStains[i].distToConvergence}  height=${params.sample.bloodStains[i].height}\n"));
        }

        avg_z += params.sample.bloodStains[i].height;
      } // if this data point is included in the calculation

    } // for each data point
    await DBService.saveToFile(filename, content);

//  average the sum over the number of points
    avg_z = avg_z /
        params
            .yNPoints; // yNPoints is the count of lines with the include=Y flag set.

//
//  Calculate the sum of the squares of the differences from the average
//
    for (int i = 0; i < params.sample.numStains; i++) {
      if (params.sample.bloodStains[i].include) {
        var diff = params.sample.bloodStains[i].height - avg_z;
        z_stddev += (diff * diff);
      }
    }

//
//  Find the standard deviation in heights.
//
    z_stddev = sqrt(z_stddev / params.yNPoints);
    params.convergenceZ = avg_z;
    params.cpZStd = z_stddev;

    return outputs;
  } // End sub calc_AO_Z_value

  Future<List<Output>> displayResults() async {
//
//  ------------------------------------------------------------------------------------------------------
//
//    At this point, we have calculated all of the required information. We have all of the intersection points of
//   all of the line segments. We also have an averaged out centroid for all of the intersection points. We have
//   also estimated the height of the Point-of-Origin (PO) for each of the blood stains and calculated an average height
//   for the PO.
//

//
//  We now display back to the user, the results of our analysis. We rebuild the original table
//  adding columns for the distance to the convergence point and the individual calculated impact heights.
//
    List<Output> outputs = [];

    outputs.add(Output("Stain Parameters:", type: Output.title)); //<h2>

    if (params.detailed) {
      outputs.add(Output(
          "Results:\nMAX_POINTS=${params.sample.numStains}, "
          "N_POINTS=${params.yNPoints}\n"));
    }
    outputs
        .add(Output("<div class='stain_heights'><P>\n")); // $chkbox   _heights

    outputs.add(Output(
        "Stain # \u03B1 Angle \u03B3 Angle Y Z"
        "Stain Dist. Height Line Dist. Include Comment",
        type: Output.title));
    NumberFormat f = NumberFormat("###0.0#");
    for (int i = 0; i < params.sample.numStains; i++) {
      //  was $MAX_POINTS 29oct2017
      outputs.add(Output("${i+1} ${f.format(params.sample.bloodStains[i].alpha)} "
          "${f.format(params.sample.bloodStains[i].gamma)} "
          "${f.format(params.sample.bloodStains[i].y)} "
          "${f.format(params.sample.bloodStains[i].z)} "
          "${f.format(params.sample.bloodStains[i].distToConvergence)} "
          "${f.format(params.sample.bloodStains[i].height)} "
          "${f.format(params.sample.bloodStains[i].dist2D)} "
          "${params.sample.bloodStains[i].getInclude} "
          "${params.sample.bloodStains[i].comment}\n"));
    }

    outputs.add(Output("Area of Origin(coord [std.dev]):\n"
        "  X = ${f.format(params.convergenceX)} [${f.format(params.cpXStd)}]\n"
        "  Y = ${f.format(params.convergenceY)} [${f.format(params.cpYStd)}]\n"
        "  Y = ${f.format(params.convergenceZ)} [${f.format(params.cpZStd)}]\n"));

    // var href1 = $HttpRoot . $HTTPimgRoot . $FileStub . "_coordinates_metod1.csv";
    // outputs.add(Output("<p> <P>Coordinate Details: <a href=\"$href1\"></a><P>\n\n"));

    String filename = params.sample.filename!.replaceAll('.csv', '');
    filename += '_coordinates_metod1.csv';
    outputs
        .add(Output("Coordinate Details", type: Output.button, link: filename));

    if (!(params.sample.teamInfo)) {
      outputs.add(Output("Data Backups", type: Output.bold));
      outputs.add(Output("WARNING: ", txtColor: Output.red));
      outputs.add(Output("You have not provided a Team Name or Pattern ID. "
          "Your data has been saved as: ${params.sample.auxFilename}"));
    }

    params.chartDataExists = true;

    return outputs;
  } // end sub display_results

  Future<void> processCharts() async {
    //  We now add to the output page, graphs showing the different plots of blood spatter points, the convergence points and impact heights.

    // // outputs.add(Output("<div class='boundary'>Charts</div>"));
    // // plot_2d_chart();

    // // String graphFile = "chart_stub";
    // // var lines;
    // // open(HTML,$HTML_stub);

    // // @lines=<HTML>;
    // // close(HTML);

    // // outputs.add(Output(@lines));
  }
}
