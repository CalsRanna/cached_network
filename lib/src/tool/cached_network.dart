import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CachedNetwork {
  CachedNetwork({this.cacheDirectory}) : _dio = Dio();
  Directory? cacheDirectory;
  final Dio _dio;

  /// Allowed method is one of [GET, PUT, PATCH, DELETE].
  ///
  /// If method is null then the default method is [GET].
  Future<String> fetch(
    String url, {
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
      var isRedirect = false;
      String data;
      do {
        var response = await _dio.fetch(RequestOptions(
          method: method,
          path: url,
        ));
        if (response.isRedirect != null && response.isRedirect == true) {
          isRedirect = true;
        }
        data = response.data;
      } while (isRedirect);
      await file.writeAsString(data);
      return data;
    } else {
      return file.readAsString();
    }
  }
}
