enum stain_comment {
  none,
  badAlphaValue,
  badGammaValue,
  badYOrZCoord,
}

class Stain {
  int id = 0;
  double alphaAngle = 0.0;
  double gammaAngle = 0.0;
  double yCoord = 0.0;
  double zCoord = 0.0;
  bool include = true;
  stain_comment? comment = stain_comment.none; // ? means it can be null

  // constructors
  Stain(this.id, this.alphaAngle, this.gammaAngle, this.yCoord, this.zCoord,
      this.include, this.comment);
  Stain.id(this.id);
}

class Dataset {
  String teamName = "";
  String patternID = "";
  int numStains = 0;
  List<Stain> stains = List.empty(growable: true);

  // constructor
  Dataset(this.teamName, this.patternID, this.numStains) {
    // initialize list of stains
    for (int i = 1; i <= numStains; ++i) {
      stains.add(Stain.id(i));
    }
  }
}
