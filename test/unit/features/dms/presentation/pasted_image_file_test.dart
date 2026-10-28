import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'zedu-pasted-image-test-',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('persists clipboard PNG bytes as a disk-backed XFile', () async {
    final bytes = Uint8List.fromList([137, 80, 78, 71, 1, 2, 3]);

    final pasted = await persistClipboardPng(
      bytes,
      directory: tempDirectory,
      uniqueId: 42,
    );

    expect(pasted.path, isNotEmpty);
    expect(
      pasted.path,
      endsWith('zedu-pasted-42${Platform.pathSeparator}Pasted Image.png'),
    );
    expect(pasted.name, 'Pasted Image.png');
    expect(pasted.mimeType, 'image/png');
    expect(await File(pasted.path).exists(), isTrue);
    expect(await File(pasted.path).readAsBytes(), bytes);
  });

  test('rejects empty clipboard image data without creating a file', () async {
    expect(
      () => persistClipboardPng(
        Uint8List(0),
        directory: tempDirectory,
        uniqueId: 42,
      ),
      throwsArgumentError,
    );
    expect(await tempDirectory.list().toList(), isEmpty);
  });

  test('uses unique paths for consecutive pasted images', () async {
    final first = await persistClipboardPng(
      Uint8List.fromList([1]),
      directory: tempDirectory,
      uniqueId: 100,
    );
    final second = await persistClipboardPng(
      Uint8List.fromList([2]),
      directory: tempDirectory,
      uniqueId: 101,
    );

    expect(first.path, isNot(second.path));
    expect(await File(first.path).readAsBytes(), [1]);
    expect(await File(second.path).readAsBytes(), [2]);
  });

  test('persists the PNG before adding it to the composer', () async {
    XFile? added;

    await persistAndAddClipboardPng(
      Uint8List.fromList([9, 8, 7]),
      addFiles: (files) async {
        added = files.single;
        expect(await File(added!.path).exists(), isTrue);
      },
      directory: tempDirectory,
      uniqueId: 200,
    );

    expect(added, isNotNull);
    expect(await added!.readAsBytes(), [9, 8, 7]);
  });

  test('does not add an attachment for empty clipboard data', () async {
    var addCalls = 0;

    await persistAndAddClipboardPng(
      Uint8List(0),
      addFiles: (_) async => addCalls++,
      directory: tempDirectory,
      uniqueId: 201,
    );

    expect(addCalls, 0);
    expect(await tempDirectory.list().toList(), isEmpty);
  });
}
