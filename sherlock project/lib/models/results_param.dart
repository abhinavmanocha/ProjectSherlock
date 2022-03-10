import 'blood_sample.dart';

class ResultParameters {
  BloodSample sample;
  double fakeZero = 2.1;

  bool detailed;
  bool chartDataExists = false;  
  
  //Stores references to the sample.bloodStains indices.
  List<int> leftStains = [];
  List<int> rightStains = [];
  List<int> verticalStains = [];

  Map<String, String> intersections = {};

  int yNPoints = 0;         // number of points included by the user.
  //  AO coordinates.
  double convergenceX=0.0;
  double convergenceY=0.0;
  double convergenceZ=0.0;
  double convergenceStd=0.0;
  // standard deviation in the X, y and z coodinates of the average convergence point.
  double cpXStd=0.0;  
  double cpYStd=0.0;
  double cpZStd=0.0;

  //Boundaries found in the data (ranges). Start with something too large and use the data to refine the estimates.
  double max_x = -9999999;
  double min_x = 99999999;
  double max_y = -9999999;
  double min_y = 99999999;
  double max_z = -9999999;
  double min_z = 99999999;
  double min_height =  99999999;
  double max_height = -99999999;

  double centre_x    = 0.0;
  double centre_y    = 0.0;
  double centre_z    = 0.0;

  ResultParameters(this.sample, {this.detailed = false});
}
