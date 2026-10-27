import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

class PhotoStorage {
  PhotoStorage();

  final _uuid = const Uuid();

  Future<Directory> _photosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, AppConstants.photosDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _thumbsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, AppConstants.thumbsDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> saveFromFile(File source, {String? preferredName}) async {
    final dir = await _photosDir();
    final ext = p.extension(source.path).isEmpty ? '.jpg' : p.extension(source.path);
    final name = preferredName ?? '${_uuid.v4()}$ext';
    final dest = File(p.join(dir.path, name));
    await source.copy(dest.path);
    return dest.path;
  }

  Future<String> saveFromAsset(String assetPath, String fileName) async {
    final dir = await _photosDir();
    final dest = File(p.join(dir.path, fileName));
    if (await dest.exists()) return dest.path;
    final data = await rootBundle.load(assetPath);
    await dest.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    return dest.path;
  }

  Future<String> saveBytes(List<int> bytes, String fileName) async {
    final dir = await _photosDir();
    final dest = File(p.join(dir.path, fileName));
    await dest.writeAsBytes(bytes, flush: true);
    return dest.path;
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<Directory> thumbsDirectory() => _thumbsDir();
}
