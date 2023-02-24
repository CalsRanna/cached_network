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

  /// Use to acquire data from network or the cached file.
  ///
  /// Allowed method is one of [GET, PUT, PATCH, DELETE].
  /// If method is null, the default method is [GET].
  ///
  /// If duration is null, the file will last forever, or will be reacquired while
  /// duration from file created to now is greater than duration specified in the
  /// param.
  Future<String> request(
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
    if (!exist || reacquire) {
      await file.create(recursive: true);
      var data = await _request(url, method);
      await file.writeAsString(data);
      return data;
    } else {
      var stat = await file.stat();
      if (stat.size == 0 ||
          (duration != null && _isExpired(stat.changed, duration))) {
        var data = await _request(url, method);
        await file.writeAsString(data);
        return data;
      }
      return file.readAsString();
    }
  }

  /// Use to fetch data from network.
  ///
  /// This function will call until the resposne has no redirect url, and return value
  /// is the content of the deepest redirect url.
  Future<String> _request(String url, String? method) async {
    var isRedirect = false;
    String data;
    do {
      var response = await dio!.fetch(RequestOptions(
        method: method,
        path: url,
      ));
      if (response.isRedirect && response.isRedirect == true) {
        isRedirect = true;
      }
      data = response.data;
    } while (isRedirect);
    return data;
  }

  bool _isExpired(DateTime createdAt, Duration duration) {
    var now = DateTime.now();
    return now.difference(createdAt).compareTo(duration) > 0;
  }
}
