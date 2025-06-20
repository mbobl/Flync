import 'package:flync/model/file_metadata.dart';
import 'package:flync/service/client/storage_client_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_action.freezed.dart';

@freezed
class FileAction with _$FileAction {
  @Assert(
    'type != ActionType.copy || to != null',
    'both sides of the connection must be specified when copying file',
  )
  factory FileAction({
    required StorageClientService from,
    StorageClientService? to,
    required FileMetadata metadata,
    required ActionType type,
    required bool shouldBackup,
  }) = _FileAction;
}

enum ActionType { delete, copy }
