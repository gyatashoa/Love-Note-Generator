import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:love_note_generator/src/generation_model.dart';
import 'package:love_note_generator/src/love_note_generation_exception.dart';
import 'package:merge_images/merge_images.dart';
import 'package:screenshot/screenshot.dart';

import 'widgets.dart';

Future<Uint8List> generateImageNoteWithUserImage(GenerationModel model,
    {bool useThread = false}) async {
  return useThread
      ? await compute(_generateImageNoteWithUserImage, model)
      : await _generateImageNoteWithUserImage(model);
}

Future<Uint8List> _generateImageNoteWithUserImage(GenerationModel model) async {
  final user = model.user;
  final note = model.note;
  final username = model.username;
  final userImage = await _getUserAvatar(user);
  final headshotPlaceholderImage =
      await img.decodeImageFile('assets/headshot_placeholder.png');
  final text = await _getTextImage(username);
  if (userImage == null || headshotPlaceholderImage == null || text == null) {
    throw LoveNoteGenerationError();
  }
  final headshotWithUserImage =
      img.compositeImage(headshotPlaceholderImage, userImage, center: true);
  final headshotWithTextImage = img.compositeImage(headshotWithUserImage, text,
      dstX: (headshotWithUserImage.width - text.width) ~/ 2,
      dstY: (headshotWithUserImage.height - text.height) ~/ 1.2);

  ui.Image image = await ImagesMergeHelper.margeImages([
    await ImagesMergeHelper.loadImageFromProvider(note),
    await ImagesMergeHelper.loadImageFromProvider(
        MemoryImage(img.encodeJpg(headshotWithTextImage)))
  ], fit: true, direction: Axis.horizontal, backgroundColor: Colors.black26);
  final uiBytes = await image.toByteData();

  final res = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: uiBytes!.buffer,
      numChannels: 4);
  return img.encodeJpg(res);
}

///------------------------------------------------------------------------------///
Future<img.Image?> _getUserAvatar(ImageProvider imageProvider) async {
  ScreenshotController controller = ScreenshotController();
  final temp = NoteImage(
    image: imageProvider,
  );
  img.decodeImage(await controller.captureFromWidget(
    temp,
  ));
  return img.decodeImage(await controller.captureFromWidget(
    temp,
  ));
}

Future<img.Image?> _getTextImage(String name) async {
  ScreenshotController controller = ScreenshotController();
  final temp = TextWidget(
    text: name,
  );
  return img.decodeImage(await controller.captureFromWidget(temp));
}
