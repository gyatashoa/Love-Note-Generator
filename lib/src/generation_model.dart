import 'package:flutter/material.dart';

class GenerationModel {
  final ImageProvider user;
  final ImageProvider note;
  final String username;

  GenerationModel(
      {required this.user, required this.note, required this.username});
}
