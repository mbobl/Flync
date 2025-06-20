import 'package:flutter/material.dart';
import 'package:flync/model/storage_source.dart';
import 'package:flync/ui/page/storage_form/config/ftp_config_form.dart';
import 'package:flync/ui/page/storage_form/config/local_config_form.dart';
import 'package:material_symbols_icons/symbols.dart';

const formFieldPadding = 16.0;

enum StorageSourceUi {
  local(
    sourceName: 'Phone memory',
    description: 'Choose a folder',
    iconData: Symbols.hard_drive,
    source: StorageSource.local,
    formConstructor: LocalConfigForm.new,
  ),
  ftp(
    sourceName: 'FTP',
    description: 'FTP Server details',
    iconData: Symbols.cloud_upload,
    source: StorageSource.ftp,
    formConstructor: FtpConfigForm.new,
  );

  const StorageSourceUi({
    required this.sourceName,
    required this.description,
    required this.iconData,
    required this.source,
    required this.formConstructor,
  });

  final String sourceName;
  final String description;
  final IconData iconData;
  final StorageSource source;
  final Widget Function() formConstructor;
}
