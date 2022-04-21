import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sherlock/models/blood_stains.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/blood_sample.dart';

class DBService {  

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path + '/blood_data';
  }

  static Future<File> _localFile(String? filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  static Future<String> saveToFile(String? filename, String content) async {
      /*
      content = 'Number of data points:20:\n'
      'beland:1701:\n'
      '26.39:8.:71.1:116.7:Y: :\n'
      '19.16:330.:35.7:130.:Y: :\n'
      '25.38:18.:80.5:119.6:Y: :\n'
      '23.04:325.:28.2:133.8:Y: :\n'
      '27.04:15.:77.3:112.4:Y: :\n'
      '33.06:341.:57.6:110.4:Y: :\n'
      '27.28:34.:88.7:114.5:Y: :\n'
      '19.47:346.:55.4:130.5:Y: :\n'
      '20.35:30.:94.4:130.4:Y: :\n'
      '21.10:329.:28.4:124.7:Y: :\n'
      '30.00:32.:88.8:112.4:Y: :\n'
      '20.35:343.:53.:118.5:Y: :\n'
      '33.75:22.:82.1:109.7:Y: :\n'
      '20.17:331.:45.3:117.5:Y: :\n'
      '22.89:14.:75.9:120.7:Y: :\n'
      '19.47:346.:55.9:124.1:Y: :\n'
      '33.06:4.:70.:117.6:Y: :\n'
      '31.33:354.:62.4:124.4:Y: :\n'
      '19.47:330.:41.7:130.8:Y: :\n'
      '26.04:360.:66.8:138.3:Y: :\n';
      */
    String auxErrors = '';
    final file = await _localFile(filename);

    if (await file.exists()) {
      await file.writeAsString(content);
      return auxErrors;
    }

    //Create file.
    try {
      await file.create(recursive: true);
    } catch (e) {
      auxErrors += 'Unable to create file\n';
      return auxErrors;
    }

    // Write to the file
    await file.writeAsString(content);
    return auxErrors;
  }

  static Future<BloodSample> saveData(BloodSample sample) async {
    sample.errors = await saveToFile(sample.filename, sample.toString());
    return sample;
  }

  static Future<BloodSample> readData(BloodSample sample) async {
    sample.errors = '';

    if (sample.filename == null || sample.filename!.isEmpty) {
      sample.errors += 'File name is empty\n';
      return sample;
    }

    try {
      final file = await _localFile(sample.filename);

      List<String> lines = await file.readAsLines();
      var len = lines.length;
      if (len < 3) {
        sample.errors += 'File have inadequate information\n';
        return sample;
      }

      //attempt to read stain count - an integer.
      var staincount = lines[0].split(':');
      if (staincount.length < 2) {
        sample.errors += 'Invalid input file format\n';
        return sample;
      }

      sample.stainCount = int.tryParse(staincount[1].trim());
      if (sample.stainCount == null) {
        sample.errors += 'Invalid stain count type\n';
        return sample;
      }

      //Retrieve team name and pattern ID.
      String aux;
      var teamPattern = lines[1].split(':');
      if (teamPattern.length < 2) {
        sample.errors += 'Invalid input file format\n';
        return sample;
      }

      aux = teamPattern[0].trim();
      sample.teamName = aux.isEmpty ? null : aux;
      sample.teamInfo = true;

      aux = teamPattern[1].trim();
      sample.patternId = aux.isEmpty ? null : aux;

      if (sample.teamName == null || sample.patternId == null) {
        sample.errors += 'Invalid team name and pattern id info\n';
        return sample;
      }

      int maxIndex = sample.stainCount! + 1;

      //No errorss so far. So read the data points for the analysis.
      for (var i = 2; i < lines.length; i++) {
        var dataPoint = lines[i].split(':');
        if (maxIndex > maxIndex || dataPoint.length < 5) {
          sample.errors += 'Invalid input file format\n';
          return sample;
        }

        final double? alpha = double.tryParse(dataPoint[0]);
        final double? gamma = double.tryParse(dataPoint[1]);
        final double? y = double.tryParse(dataPoint[2]);
        final double? z = double.tryParse(dataPoint[3]);
        final bool? include = dataPoint[4] == "Y" ? true : false;

        if (alpha == null ||
            gamma == null ||
            y == null ||
            z == null ||
            include == null) {
          sample.errors += 'Invalid stain values.\n';
          return sample;
        }

        sample.bloodStains.add(BloodStain(
            alpha: alpha, gamma: gamma, y: y, z: z, include: include));
      }
    } catch (e) {
      sample.errors += 'Failed to find file to read\n';
    }

    return sample;
  }
}
