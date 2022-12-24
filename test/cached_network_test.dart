import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cached_network/cached_network.dart';

void main() {
  test('Cache baidu', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final network = CachedNetwork();
    final response = await network.request('http://www.baidu.com');
    expect(response, '');
  });
}
