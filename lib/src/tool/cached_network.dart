import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CachedNetwork {
  CachedNetwork({this.cacheDirectory, this.dio}) {
    dio ??= Dio();
  }
  Directory? cacheDirectory;
  Dio? dio;

  /// Use to fetch data from network or cache file.
  ///
  /// Allowed method is one of [GET, PUT, PATCH, DELETE].
  /// If method is null then the default method is [GET].
  ///
  /// If duration is null the the file will last forever, or should be reacquired
  /// while duration from file created is longer than duration specified in the param.
  Future<String> fetch(
    String url, {
    Duration? duration,
    String? method,
    bool reacquire = false,
  }) async {
    cacheDirectory ??= await getTemporaryDirectory();
    var hash = md5.convert(utf8.encode(url));
    var file = File(path.join(
      cacheDirectory!.path,
      'libCachedNetworkData',
      hash.toString(),
    ));
    var exist = await file.exists();
    if (exist == false || reacquire == true) {
      await file.create(recursive: true);
      var data = await _fetchFromNetwork(url, method);
      await file.writeAsString(data);
      return data;
    } else {
      if (duration != null) {
        var createdAt = file.statSync().changed;
        var now = DateTime.now();
        if (now.difference(createdAt).compareTo(duration) > 0) {
          var data = await _fetchFromNetwork(url, method);
          await file.writeAsString(data);
          return data;
        }
      }
      return file.readAsString();
    }
  }

  /// Use to fetch data from network but do not expose.
  Future<String> _fetchFromNetwork(String url, String? method) async {
    var isRedirect = false;
    String data;
    do {
      var response = await dio!.fetch(RequestOptions(
        method: method,
        path: url,
      ));
      if (response.isRedirect != null && response.isRedirect == true) {
        isRedirect = true;
      }
      data = response.data;
    } while (isRedirect);
    return data;
  }
}
