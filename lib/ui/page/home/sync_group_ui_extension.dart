import 'package:flutter/material.dart';
import 'package:flync/model/storage_config.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/ui/page/storage_form/config/storage_source_ui.dart';
import 'package:humanizer/humanizer.dart';
import 'package:intl/intl.dart';

extension SyncGroupUiExtension on SyncGroup {
  static final dateFormat = DateFormat('EEE dd/MM, HH:mm');
  static final sizeFormat = InformationSizeFormat(
    permissibleValueUnits: InformationUnits.siBytes,
  );

  String get statusText => 'Status: $_textForStatus';

  String get contentText =>
      'Content: ${fileSnapshot == null ? '' : '${fileSnapshot!.length} files (${sizeFormat.format(totalSize)})'}';

  String get modifiedDateText =>
      'Modified: ${fileSnapshot == null || fileSnapshot!.isEmpty ? '' : dateFormat.format(modifiedAt!)}';

  InformationSize get totalSize =>
      fileSnapshot?.fold(0, (prev, element) => prev + element.size).bytes() ??
      0.bytes();

  DateTime? get modifiedAt => fileSnapshot
      ?.map((f) => f.modified)
      .reduce((latest, current) => current.isAfter(latest) ? current : latest);

  IconData? get statusIcon => switch (_nonTransientStatus) {
    SyncStatus.synchronized => Icons.done_all,
    SyncStatus.failure => Icons.close,
    _ => null,
  };

  List<(IconData, String)> get uiConfigs =>
      configs.map((c) => (_iconForConfig(c), c.directory!)).toList();

  SyncStatus get _nonTransientStatus =>
      status != SyncStatus.inProgress ? status : lastStatus ?? status;

  String get _textForStatus => switch (_nonTransientStatus) {
    SyncStatus.synchronized => 'Synchronized',
    SyncStatus.failure => 'Failure',
    _ => '',
  };

  IconData _iconForConfig(StorageConfig config) =>
      StorageSourceUi.values
          .firstWhere((s) => s.source == config.source)
          .iconData;

  bool get inProgress => status == SyncStatus.inProgress;
}
