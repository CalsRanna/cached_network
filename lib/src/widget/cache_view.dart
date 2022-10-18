import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheView extends StatefulWidget {
  const CacheView({super.key});

  @override
  State<CacheView> createState() => _CacheViewState();
}

class _CacheViewState extends State<CacheView> {
  late Directory directory;
  List<FileSystemEntity> files = [];
  bool isRoot = true;

  @override
  void initState() {
    fetchFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 3;
    final ratio = width / (width + 56);
    return Scaffold(
      appBar: AppBar(
        actions: !isRoot
            ? [
                IconButton(
                  onPressed: backward,
                  icon: const Icon(Icons.arrow_upward_outlined),
                )
              ]
            : null,
        title: const Text('Cached View'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: ratio,
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => forward(files[index]),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14, height: 1),
            textAlign: TextAlign.center,
            child: Column(
              children: [
                Icon(
                  isDirectory(files[index])
                      ? Icons.folder_outlined
                      : Icons.description_outlined,
                  color: Colors.black.withOpacity(0.4),
                  size: width,
                ),
                Text(getName(files[index]), maxLines: 2),
                Text(getDate(files[index]), maxLines: 1),
                if (!isDirectory(files[index]))
                  Text(getSize(files[index]), maxLines: 1)
              ],
            ),
          ),
        ),
        itemCount: files.length,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  void fetchFiles() async {
    var cacheDirectory = await getTemporaryDirectory();
    setState(() {
      directory = cacheDirectory;
      files = cacheDirectory.listSync();
    });
  }

  void backward() async {
    var cacheDirectory = await getTemporaryDirectory();
    var parent = directory.parent;
    setState(() {
      directory = directory.parent;
      files = directory.listSync();
      isRoot = parent.path == cacheDirectory.path;
    });
  }

  void forward(FileSystemEntity entity) {
    if (isDirectory(entity)) {
      setState(() {
        directory = Directory(entity.path);
        files = Directory(entity.path).listSync();
        isRoot = false;
      });
    }
  }

  bool isDirectory(FileSystemEntity entity) {
    var stat = entity.statSync();
    return stat.type == FileSystemEntityType.directory;
  }

  String getName(FileSystemEntity entity) {
    return entity.path.split('/').last;
  }

  String getDate(FileSystemEntity entity) {
    var date = entity.statSync().changed;
    return '${date.year}/${date.month}/${date.day}';
  }

  String getSize(FileSystemEntity entity) {
    var size = entity.statSync().size;
    String string;
    if (size < 1024) {
      string = '$size Bytes';
    } else if (size >= 1024 && size < 1024 * 1024) {
      string = '${size / 1024} KB';
    } else {
      string = '${size / 1024 / 1024} MB';
    }
    return string;
  }
}
