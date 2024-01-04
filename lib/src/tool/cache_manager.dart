import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CacheManager {
  String identifier = 'libCachedNetworkData';
  String? prefix;
  Directory? temporaryDirectory;

  CacheManager({this.prefix, this.temporaryDirectory});

  Future<bool> clearCache() async {
    try {
      final directory = await _generateDirectory();
      await directory.delete(recursive: true);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<int> getCacheSize() async {
    final directory = await _generateDirectory();
    final files = directory.listSync(recursive: true);
    List<int> sizes = [];
    for (var file in files) {
      final stat = await file.stat();
      sizes.add(stat.size);
    }
    return sizes.reduce((value, size) => value + size);
  }

  Future<Directory> _generateDirectory() async {
    temporaryDirectory ??= await getTemporaryDirectory();
    String directoryPath;
    if (prefix != null) {
      directoryPath = path.join(temporaryDirectory!.path, identifier, prefix);
    } else {
      directoryPath = path.join(temporaryDirectory!.path, identifier);
    }
    return Directory(directoryPath);
  }
}
