import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

Future<Uint8List> generateImageNoteWithUserImageV2(
    {required String text,
    required ImageProvider userImage,
    required Widget noteImage}) async {
  ScreenshotController controller = ScreenshotController();
  return await controller.captureFromWidget(FullGenerationWidget(
      userImage: userImage, noteImage: noteImage, text: text));
}

Future<Uint8List> _generateImageNoteWithUserImage(GenerationModel model) async {
  final user = model.user;
  final note = model.note;
  final username = model.username;
  final userImage = await _getUserAvatar(user);
  ByteData bytes = await rootBundle.load('assets/headshot_placeholder.png');
  final headshotPlaceholderImage = img.decodeImage(bytes.buffer.asUint8List());
  final text = await _getTextImage(username, model.fontSize);
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
    await ImagesMergeHelper.loadImageFromProvider(MemoryImage(
        img.encodePng(headshotWithTextImage, filter: img.PngFilter.up)))
  ], fit: true, direction: Axis.horizontal, backgroundColor: Colors.black26);
  final uiBytes = await image.toByteData();

  final res = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: uiBytes!.buffer,
      numChannels: 4);
  return img.encodePng(res, filter: img.PngFilter.up);
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

Future<img.Image?> _getTextImage(String name, double fontSize) async {
  ScreenshotController controller = ScreenshotController();
  final temp = TextWidget(
    text: name,
    fontSize: fontSize,
  );
  return img.decodeImage(await controller.captureFromWidget(temp));
}
