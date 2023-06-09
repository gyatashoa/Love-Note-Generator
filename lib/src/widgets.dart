import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.text, required this.fontSize});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          package: 'love_note_generator',
          fontFamily: 'Carlsonscript',
          color: Colors.red,
          fontSize: fontSize),
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
          border: Border.all(color: Colors.red, width: 15),
          image: DecorationImage(
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              image: image),
          shape: BoxShape.circle),
    );
  }
}

class FullGenerationWidget extends StatelessWidget {
  const FullGenerationWidget(
      {super.key,
      required this.userImage,
      required this.noteImage,
      required this.text});
  final ImageProvider userImage;
  final Widget noteImage;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        noteImage,
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/headshot_placeholder.png',
              package: 'love_note_generator',
            ),
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 8),
                  image: DecorationImage(
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                      image: userImage),
                  shape: BoxShape.circle),
            ),
            Positioned(
              bottom: 200,
              child: DefaultTextStyle(
                style: const TextStyle(
                    fontFamily: 'Carlsonscript',
                    color: Colors.red,
                    package: 'love_note_generator',
                    fontSize: 50),
                child: Text(
                  text,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
