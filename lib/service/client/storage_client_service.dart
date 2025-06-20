import 'dart:io';

import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/storage_config.dart';

abstract class StorageClientService {
  final StorageConfig config;

  StorageClientService({required this.config});

  Future<void> validate();
  Future<void> connect();
  Future<void> disconnect();
  Future<Set<FileMetadata>> getFiles();
  Future<File> download(String fileName);
  Future<void> upload(File file);
  Future<void> delete(String fileName);
  bool isSettingModifyTimeSupported();
  Future<void> setModifyTime(String fileName, DateTime time);
}
