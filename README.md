# Cached Network

This is a package use to fetch data from web and write as string into cache directory. If the cache file exists, then will read data from cache file instead of web.
Besides, it provides a widget use to view caches.

## Install

```bash
flutter pub add cached_network
```

## Getting started

`CachedNetwork`

```dart
import 'package:cached_network/cached_network.dart';

void main() async {
  var network = CachedNetwork();
  await network.fetch('https://google.com');
}
```

`CacheView`

```dart
import 'package:cached_network/cached_network.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: CacheViewDemo(),
  ));
}

class CacheViewDemo extends StatelessWidget {
  const CacheViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const CacheView();
  }
}
```

## Important

If you use CachedNetwork not in flutter or in isolate, you should specify the `cacheDirectory` when you construct the instance.
