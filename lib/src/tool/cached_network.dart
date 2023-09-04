import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CachedNetwork {
  CachedNetwork({this.cacheDirectory, this.timeout});

  Directory? cacheDirectory;
  Duration? timeout;

  /// Use to acquire data from network or the cached file.
  ///
  /// Allowed method is one of [GET, POST].
  /// If method is null, the default method is [GET].
  ///
  /// If duration is null, the file will last forever, or will be reacquired while
  /// duration from file created to now is greater than duration specified in the
  /// param.
  Future<String> request(
    String url, {
    Map<String, dynamic>? body,
    String? charset,
    Duration? duration,
    String? method,
    bool reacquire = false,
  }) async {
    timeout ??= const Duration(seconds: 10);
    final valid = await _valid(url, duration: duration);
    if (!valid || reacquire) {
      final data = await _request(
        body: body,
        charset: charset,
        method: method,
        url: url,
      ).timeout(timeout!);
      await _cache(url, data);
      return data;
    } else {
      final file = await _generate(url);
      return file.readAsString();
    }
  }

  /// Check the given url is cached or not.
  Future<bool> cached(String url) async {
    cacheDirectory ??= await getTemporaryDirectory();
    const prefix = 'libCachedNetworkData';
    final hash = md5.convert(utf8.encode(url)).toString();
    final file = File(path.join(cacheDirectory!.path, prefix, hash));
    return file.exists();
  }

  /// Clear all cached file.
  Future<bool> clearCache() async {
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      const prefix = 'libCachedNetworkData';
      final directory = Directory(path.join(temporaryDirectory.path, prefix));
      await directory.delete(recursive: true);
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Validate the cached file.
  ///
  /// If the file exists and size is greater than 0, and the file is not expired,
  ///  return true.
  Future<bool> _valid(String url, {Duration? duration}) async {
    final file = await _generate(url);
    final exist = await file.exists();
    final stat = await file.stat();
    final size = stat.size;
    final createdAt = stat.changed;
    final now = DateTime.now();
    final permanent = duration == null;
    var expired = false;
    if (!permanent) {
      expired = now.difference(createdAt).compareTo(duration) > 0;
    }
    return exist && size > 0 && !expired;
  }

  /// Use to generate cache file.
  ///
  /// The file will be saved in [cacheDirectory].
  Future<File> _generate(String url) async {
    cacheDirectory ??= await getTemporaryDirectory();
    const prefix = 'libCachedNetworkData';
    final hash = md5.convert(utf8.encode(url)).toString();
    return File(path.join(cacheDirectory!.path, prefix, hash));
  }

  /// Use to fetch data from network.
  ///
  /// This function will return the plain text no matter has redirect or not.
  Future<String> _request({
    Map<String, dynamic>? body,
    String? charset,
    String? method,
    required String url,
  }) async {
    final uri = Uri.parse(url);
    http.Response response;
    if (method?.toLowerCase() == 'post') {
      response = await http.post(uri, body: body);
    } else {
      response = await http.get(uri);
    }
    if (charset == 'gbk') {
      return gbk.decode(response.bodyBytes, allowMalformed: true);
    } else {
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    }
  }

  /// Use to cache data.
  ///
  /// Write content to file
  Future<void> _cache(String url, String content) async {
    final file = await _generate(url);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }
}
