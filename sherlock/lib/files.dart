// this file contains the methods needed for reading and writing to files

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileManager {
  static String filename = "";
  // get documents directory path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // set local file path
  static Future<File> get _localFile async {
    final path = await _localPath;
    String filepath = "$path/" + filename;
    return File(filepath).create(recursive: true);
  }

  // write data to file
  static Future<File> writeFile(String name, String data) async {
    filename = name;
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }

  // read data from file
  static Future<List<List<String>>> readFile(String name) async {
    List<List<String>> contents = List.empty(growable: true);
    try {
      filename = name;
      Stream<String> lines;
      if (filename == "sample") {
        lines = Stream.fromFuture(
                rootBundle.loadString("sampledata/beland_1701.csv"))
            .transform(const LineSplitter());
      } else {
        final file = await _localFile;
        lines = file.openRead().transform(utf8.decoder).transform(
            const LineSplitter()); // Convert stream to individual lines
      }

      try {
        await for (var line in lines) {
          contents.add(line.split(":"));
        }
        // ignore: empty_catches
      } catch (e) {}

      // Read the file
      return contents;
    } catch (e) {
      // If encountering an error, return empty list
      return contents;
    }
  }
}
