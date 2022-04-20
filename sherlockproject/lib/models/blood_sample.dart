import 'blood_stains.dart';

class BloodSample {
  bool isNew;
  String? teamName;
  String? patternId;
  int? stainCount;
  String? filename;
  String auxFilename;
  bool teamInfo = false;
  List<BloodStain> bloodStains = [];
  //List<String> errors = [];
  String errors = "";

  BloodSample(
      {required this.isNew,
      this.teamName,
      this.patternId,
      this.stainCount = 0,
      this.filename}) : auxFilename = genFilename;

  // String genFilename() {
  //   return (teamName ?? "data") +
  //       '_' +
  //       (patternId ?? "") +
  //       DateTime.now().microsecondsSinceEpoch.toString() +
  //       '.csv';
  // }

  static String get genFilename {
    return "team_id_" + DateTime.now().millisecondsSinceEpoch.toString();
  }

  int get numStains {
    return stainCount ?? 0;
  }

  initBloodStains() {
    bloodStains = [];
    for (int i = 0; i < numStains; i++) {
      bloodStains.add(BloodStain());
    }
  }

  @override
  String toString() {
    int numStains = stainCount ?? 0;
    String str = 'Number of data points:$numStains:\n';
    str += '${teamName ?? ""}:${patternId ?? ""}:\n';

    for (int i = 0; i < numStains; i++) {
      str += bloodStains[i].toString();
    }
    return str;
  }
}
