import 'dart:io';

import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/storage_config.dart';
import 'package:flync/service/client/storage_client_service.dart';
import 'package:path/path.dart';

class LocalClient implements StorageClientService {
  @override
  final StorageConfig config;

  final String _path;

  LocalClient({required this.config})
    : assert(config.directory?.isNotEmpty ?? false),
      _path = config.directory!;

  @override
  Future<void> validate() async {
    var exists = await Directory(_path).exists();
    if (!exists) {
      return Future.error(PathNotFoundException(_path, OSError()));
    }
  }

  @override
  connect() async {}

  @override
  disconnect() async {}

  @override
  Future<Set<FileMetadata>> getFiles() {
    return Future.value(
      Directory(_path)
          .list()
          .where((f) => f is File)
          .map((f) => f as File)
          .map(
            (f) => FileMetadata(
              name: basename(f.path),
              size: f.lengthSync(),
              modified: f.lastModifiedSync(),
            ),
          )
          .toSet(),
    );
  }

  @override
  Future<File> download(String fileName) async {
    return File('$_path/$fileName');
  }

  @override
  Future<void> upload(File file) async {
    await file.copy('$_path/${basename(file.path)}');
  }

  @override
  Future<void> delete(String fileName) async {
    await File('$_path/$fileName').delete();
  }

  @override
  bool isSettingModifyTimeSupported() {
    return true;
  }

  @override
  Future<void> setModifyTime(String fileName, DateTime time) async {
    await File('$_path/$fileName').setLastModified(time);
  }
}
