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
