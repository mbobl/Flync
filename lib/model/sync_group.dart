import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/storage_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_group.freezed.dart';
part 'sync_group.g.dart';

@freezed
class SyncGroup with _$SyncGroup {
  const factory SyncGroup({
    required List<StorageConfig> configs,
    required SyncStatus status,
    SyncStatus? lastStatus,
    required int syncCount,
    Set<FileMetadata>? fileSnapshot,
  }) = _SyncGroup;

  factory SyncGroup.fromJson(Map<String, Object?> json) =>
      _$SyncGroupFromJson(json);
}

enum SyncStatus { inProgress, synchronized, failure }
