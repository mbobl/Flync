import 'dart:io';

import 'package:file/memory.dart';
import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/storage_config.dart';
import 'package:flync/model/storage_source.dart';
import 'package:flync/service/client/storage_client_service.dart';
import 'package:path/path.dart';

class FakeFile {
  List<int> content;
  DateTime modified;

  FakeFile(this.content, this.modified);
}

class FakeStorageClient implements StorageClientService {
  FakeStorageClient({this.supportsModifyTime = true, DateTime? uploadClock})
    : uploadClock = uploadClock ?? DateTime(2026, 1, 1);

  final bool supportsModifyTime;

  DateTime uploadClock;

  final files = <String, FakeFile>{};
  int connectCount = 0;
  int disconnectCount = 0;

  final _fs = MemoryFileSystem();

  void put(String name, String content, DateTime modified) {
    files[name] = FakeFile(content.codeUnits, modified);
  }

  String contentOf(String name) => String.fromCharCodes(files[name]!.content);

  Map<String, String> get contents =>
      files.map((name, _) => MapEntry(name, contentOf(name)));

  @override
  StorageConfig get config =>
      const StorageConfig(source: StorageSource.local, directory: '/fake');

  @override
  Future<void> validate() async {}

  @override
  Future<void> connect() async {
    connectCount++;
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }

  @override
  Future<Set<FileMetadata>> getFiles() async =>
      files.entries
          .map(
            (e) => FileMetadata(
              name: e.key,
              size: e.value.content.length,
              modified: e.value.modified,
            ),
          )
          .toSet();

  @override
  Future<File> download(String fileName) async {
    final file = _fs.file('/transfer/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(files[fileName]!.content);
    return file;
  }

  @override
  Future<void> upload(File file) async {
    files[basename(file.path)] = FakeFile(await file.readAsBytes(), uploadClock);
  }

  @override
  Future<void> delete(String fileName) async {
    files.remove(fileName);
  }

  @override
  bool isSettingModifyTimeSupported() => supportsModifyTime;

  @override
  Future<void> setModifyTime(String fileName, DateTime time) async {
    if (!supportsModifyTime) {
      throw UnsupportedError('This fake does not support setting modify time.');
    }
    files[fileName]!.modified = time;
  }
}
