import 'package:flutter/material.dart';

class Output {
  String content; //text
  String type; //normal, bold, title, button
  Color? txtColor;
  String link;

  static const String button = 'button';
  static const String normal = 'normal';
  static const String bold = 'bold';
  static const String title = 'title';
  static const Color? red = Colors.red;

  Output(this.content, {this.type = 'normal', this.txtColor = Colors.black, this.link = ''});
}
