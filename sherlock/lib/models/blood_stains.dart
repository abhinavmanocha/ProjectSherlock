//BloodStain reprsents a single BlodStain sample.
import 'package:sherlock/models/stain_comment.dart';
import 'package:vector_math/vector_math.dart';

class BloodStain {
  //Input values.
  double alpha, gamma; //alpha and gamma angles.
  double y, z; //x, y and z coordinates.
  bool include; //Either Y or N.
  StainComment comment;

  //Computed values.
  double x = 0, x2 = 0, x3 = 0; //x coordinates.
  double z2 = 0, z3 = 0; //2nd and 3rd z points.
  double y2 = 0, y3 = 0; //x coordinates. 
  double deltaX=0.0, deltaY=0.0, deltaZ=0.0; //delta x,y,z useful for creating the 3d
                                       // equation for the line x=x0+t Delta_x.
  double parametric=0; // parametric equations for each line
  double dist2D=0;  // distance of each line in the X-Y plane from the average point of intersection. 
  double height=0.0, width=0.0;
  double distToConvergence=0;
  String? quadrant; //Either Y for vertical, R for right, or L for left.

  BloodStain({
    this.alpha = 0.0,
    this.gamma = 0.0,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
    this.include = true,
    this.comment = StainComment.none,
  });

  double get alphaAsRad {
    return radians(alpha);
  }

  double get gammaAsRad {
    return radians(gamma);
  }

  String get getInclude {
    return (include == true ? "Y" : "N");
  }

  set setInclude(String value) {
    if (value == "Y") {
      include = true;
    } else if (value == "N") {
      include = false;
    }
  }

  @override
  String toString() {
    return '$alpha:$gamma:$y:$z:$getInclude:$comment\n';
  }
}
