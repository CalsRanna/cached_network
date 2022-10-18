import 'package:flutter_test/flutter_test.dart';

import 'package:cached_network/cached_network.dart';

void main() {
  test('Cache baidu', () async {
    final network = CachedNetwork();
    final response = await network.fetch('http://www.baidu.com');
    expect(response, '');
  });
}
