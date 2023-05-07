import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.red, fontSize: 200),
    );
  }
}

class NoteImage extends StatelessWidget {
  const NoteImage({super.key, required this.image});
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      width: 800,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 30),
          image: DecorationImage(
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              image: image),
          shape: BoxShape.circle),
    );
  }
}
