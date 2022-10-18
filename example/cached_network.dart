import 'package:cached_network/cached_network.dart';

void main() async {
  var network = CachedNetwork();
  final response = await network.fetch('https://google.com');
}
