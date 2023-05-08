import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  final note = await ImagesMergeHelper.loadImageFromProvider(model.note);
  final username = model.username;
  final userImage = await _getUserAvatar(user);
  ByteData bytes = await rootBundle.load('assets/headshot_placeholder.png');
  final text = await _getTextImage(username, model.fontSize);
  if (userImage == null || text == null) {
    throw LoveNoteGenerationError();
  }

  return await compute(
      _generate,
      _Model(
          note: note,
          quality: model.quality,
          placeholder: bytes,
          text: text,
          image: userImage));
}

Future<Uint8List> _generate(_Model model) async {
  // WidgetsFlutterBinding.ensureInitialized();
  final headshotPlaceholderImage =
      img.decodeImage(model.placeholder.buffer.asUint8List());
  final headshotWithUserImage =
      img.compositeImage(headshotPlaceholderImage!, model.image, center: true);
  final headshotWithTextImage = img.compositeImage(
      headshotWithUserImage, model.text,
      dstX: (headshotWithUserImage.width - model.text.width) ~/ 2,
      dstY: (headshotWithUserImage.height - model.text.height) ~/ 1.2);

  // img.decodeImage(data)
  ui.Image image = await ImagesMergeHelper.margeImages([
    model.note,
    await ImagesMergeHelper.loadImageFromProvider(MemoryImage(img.encodePng(
        headshotWithTextImage,
        level: 2,
        filter: img.PngFilter.none)))
  ], fit: true, direction: Axis.horizontal, backgroundColor: Colors.black26);
  final uiBytes = await image.toByteData();

  final res = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: uiBytes!.buffer,
      numChannels: 4);
  return await FlutterImageCompress.compressWithList(
      img.encodePng(res, level: 2, filter: img.PngFilter.none),
      format: CompressFormat.png,
      quality: model.quality);
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

class _Model {
  final ByteData placeholder;
  final img.Image text;
  final img.Image image;
  final int quality;
  final ui.Image note;

  _Model(
      {required this.placeholder,
      required this.quality,
      required this.note,
      required this.text,
      required this.image});
}

Future<ui.Image> _convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  ui.ImmutableBuffer buffer =
      await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

  ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
      height: image.height,
      width: image.width,
      pixelFormat: ui.PixelFormat.rgba8888);

  ui.Codec codec = await id.instantiateCodec(
      targetHeight: image.height, targetWidth: image.width);

  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image uiImage = fi.image;

  return uiImage;
}
