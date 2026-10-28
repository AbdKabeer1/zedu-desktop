import 'dart:io';
import 'dart:typed_data';

import 'package:zedu/core/core.dart';

Future<XFile> persistClipboardPng(
  Uint8List bytes, {
  Directory? directory,
  int? uniqueId,
}) async {
  if (bytes.isEmpty) {
    throw ArgumentError.value(bytes, 'bytes', 'Clipboard image is empty.');
  }

  final targetDirectory = directory ?? Directory.systemTemp;
  var id = uniqueId ?? DateTime.now().microsecondsSinceEpoch;
  Directory pasteDirectory;
  do {
    pasteDirectory = Directory(
      '${targetDirectory.path}${Platform.pathSeparator}zedu-pasted-$id',
    );
    id++;
  } while (await pasteDirectory.exists());

  await pasteDirectory.create(recursive: true);
  final target = File(
    '${pasteDirectory.path}${Platform.pathSeparator}Pasted Image.png',
  );
  await target.writeAsBytes(bytes, flush: true);
  return XFile(
    target.path,
    mimeType: 'image/png',
    name: 'Pasted Image.png',
  );
}
