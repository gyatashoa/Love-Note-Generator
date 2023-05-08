import 'package:flutter/material.dart';

class GenerationModel {
  final ImageProvider user;
  final ImageProvider note;
  final String username;
  final double fontSize;
  final int quality;

  GenerationModel(
      {required this.user,
      this.fontSize = 100,
      this.quality = 50,
      required this.note,
      required this.username});
}
