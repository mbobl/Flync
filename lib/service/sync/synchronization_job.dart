import 'package:flync/model/file_metadata.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/client/storage_client_service.dart';
import 'package:flync/service/sync/file_action.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class SynchronizationJob {
  final StorageClientService _protocol1;
  final StorageClientService _protocol2;
  final Set<FileMetadata> _fileSnapshot;

  var _firstFiles = <FileMetadata>{};
  var _secondFiles = <FileMetadata>{};
  var _includeModifyInEqualityComparison = true;

  //TODO: Refactor pair to group
  SynchronizationJob(SyncGroup group)
    : _protocol1 = group.configs[0].source.client(config: group.configs[0]),
      _protocol2 = group.configs[1].source.client(config: group.configs[1]),
      _fileSnapshot = group.fileSnapshot ?? {};

  synchronize() async {
    await _protocol1.connect();
    await _protocol2.connect();

    _firstFiles = await _protocol1.getFiles();
    _secondFiles = await _protocol2.getFiles();

    _includeModifyInEqualityComparison =
        _protocol1.isSettingModifyTimeSupported() &&
        _protocol2.isSettingModifyTimeSupported();

    var actions = await _computeNecessaryActions();

    for (var action in actions) {
      await _handleAction(action);
    }

    await _protocol1.disconnect();
    await _protocol2.disconnect();
  }

  //TODO: What if structure was modified between sync and getting snapshot
  Future<Set<FileMetadata>> createSnapshot() async {
    if (_protocol1.isSettingModifyTimeSupported()) {
      return _getFilesWithConnection(_protocol1);
    }
    return _getFilesWithConnection(_protocol2);
  }

  Future<List<FileAction>> _computeNecessaryActions() async {
    var firstNames = _firstFiles.map((f) => f.name).toSet();
    var secondNames = _secondFiles.map((f) => f.name).toSet();

    var nameDifference = symmetricDifference(firstNames, secondNames);
    var nameIntersection = firstNames.intersection(secondNames);

    return _handleDeletionsAndCreations(nameDifference) +
        _handleConflicts(nameIntersection);
  }

  List<FileAction> _handleDeletionsAndCreations(
    Set<String> deletedOrCreatedFileNames,
  ) {
    var result = <FileAction>[];

    for (var name in deletedOrCreatedFileNames) {
      var firstFile = _firstFiles.firstWhereOrNull((f) => f.name == name);
      var secondFile = _secondFiles.firstWhereOrNull((f) => f.name == name);

      result.add(
        _constructFileAction(
          _fileSnapshot.any((f) => f.name == name)
              ? ActionType.delete
              : ActionType.copy,
          firstFile,
          secondFile,
        ),
      );
    }

    return result;
  }

  List<FileAction> _handleConflicts(Set<String> conflictingFileNames) {
    var result = <FileAction>[];

    for (var name in conflictingFileNames) {
      var firstFile = _firstFiles.firstWhere((f) => f.name == name);
      var secondFile = _secondFiles.firstWhere((f) => f.name == name);

      if (firstFile.size != secondFile.size &&
          !_modifiedTimesAreSame(firstFile, secondFile)) {
        result.add(
          _constructFileAction(ActionType.copy, firstFile, secondFile),
        );
      }
    }

    return result;
  }

  bool _modifiedTimesAreSame(FileMetadata firstFile, FileMetadata secondFile) {
    return _includeModifyInEqualityComparison &&
        firstFile.modified.isAtSameMomentAs(secondFile.modified);
  }

  //TODO: Handle backups
  _handleAction(FileAction fileAction) async {
    var name = fileAction.metadata.name;

    if (fileAction.type == ActionType.delete) {
      await fileAction.from.delete(name);
    }
    if (fileAction.type == ActionType.copy) {
      var file = await fileAction.from.download(name);
      await fileAction.to!.upload(file);
      await _matchModifyTimeIfPossible(
        fileAction.to!,
        name,
        fileAction.metadata.modified,
      );
    }
  }

  _matchModifyTimeIfPossible(
    StorageClientService protocol,
    String fileName,
    DateTime modified,
  ) async {
    if (protocol.isSettingModifyTimeSupported()) {
      await protocol.setModifyTime(fileName, modified);
    }
  }

  FileAction _constructFileAction(
    ActionType type,
    FileMetadata? firstFile,
    FileMetadata? secondFile,
  ) {
    if (type == ActionType.delete) {
      return FileAction(
        from: firstFile != null ? _protocol1 : _protocol2,
        metadata: firstFile ?? secondFile!,
        type: ActionType.delete,
        shouldBackup: true,
      );
    }

    if (firstFile == null || secondFile == null) {
      return FileAction(
        from: firstFile != null ? _protocol1 : _protocol2,
        to: firstFile != null ? _protocol2 : _protocol1,
        metadata: firstFile ?? secondFile!,
        type: ActionType.copy,
        shouldBackup: false,
      );
    }

    var isFirstNewer = firstFile.modified.isAfter(secondFile.modified);
    return FileAction(
      from: isFirstNewer ? _protocol1 : _protocol2,
      to: isFirstNewer ? _protocol2 : _protocol1,
      metadata: isFirstNewer ? firstFile : secondFile,
      type: ActionType.copy,
      shouldBackup: false,
    );
  }

  Future<Set<FileMetadata>> _getFilesWithConnection(protocol) async {
    await protocol.connect();
    var result = await protocol.getFiles();
    await protocol.disconnect();
    return result;
  }

  Set<T> symmetricDifference<T>(Set<T> set1, Set<T> set2) {
    return set1.difference(set2).union(set2.difference(set1));
  }
}
