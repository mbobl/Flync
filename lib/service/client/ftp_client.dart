import 'dart:io';

import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/storage_config.dart';
import 'package:flync/service/client/storage_client_service.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

class FtpClient implements StorageClientService {
  @override
  final StorageConfig config;

  final FTPConnect _session;

  FtpClient({required this.config})
    : assert(
        (config.hostname?.isNotEmpty ?? false) &&
            (config.username?.isNotEmpty ?? false),
      ),
      _session = FTPConnect(
        config.hostname!,
        user: config.username!,
        pass: config.password ?? '',
      );

  @override
  Future<void> validate() async {
    await _session.connect();
    if (config.directory != null) {
      await _session.changeDirectory(config.directory!);
    }
    await _session.disconnect();
  }

  @override
  connect() async {
    await _session.connect();

    _session.listCommand =
        ListCommand.LIST; //TODO: Try which is supported by server
    if (config.directory != null) {
      await _session.changeDirectory(config.directory!);
    }
  }

  @override
  Future<Set<FileMetadata>> getFiles() {
    return _session.listDirectoryContent().then(
      (c) =>
          c
              .where((e) => e.type == FTPEntryType.FILE)
              .map(
                (f) => FileMetadata(
                  name: f.name,
                  size: f.size!,
                  modified: f.modifyTime!,
                ),
              )
              .toSet(),
    );
  }

  @override
  Future<File> download(String fileName) async {
    var temp = await getTemporaryDirectory();
    var result = File('${temp.path}/$fileName');
    await _session.downloadFile(fileName, result);
    return result;
  }

  @override
  Future<void> upload(File file) async {
    await _session.uploadFile(file);
  }

  @override
  Future<void> delete(String fileName) async {
    await _session.deleteFile(fileName);
  }

  @override
  disconnect() async {
    await _session.disconnect();
  }

  @override
  bool isSettingModifyTimeSupported() {
    return false; //This could be true, depending on supported FTP commands
  }

  @override
  Future<void> setModifyTime(String fileName, DateTime time) {
    return Future.error(
      UnsupportedError("This FTP server doesn't support setting modify time."),
    );
  }
}
