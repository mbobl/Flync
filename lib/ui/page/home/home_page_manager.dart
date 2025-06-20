import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/persistence_service.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/service/sync/sync_service.dart';
import 'package:flync/ui/page/home/sync_group_list_notifier.dart';
import 'package:flync/ui/page/home/sync_groups_count_notifier.dart';

class HomePageManager {
  final syncGroupsCountNotifier = SyncGroupsCountNotifier();
  final syncGroupsNotifier = SyncGroupListNotifier();

  final PersistenceService _persistenceService = getIt<PersistenceService>();
  final SyncService _syncService = getIt<SyncService>();

  HomePageManager() {
    _retryInProgressSyncs();
  }

  onClickSync(int groupId) async {
    var group = _persistenceService.get(groupId);
    if (group == null || group.status == SyncStatus.inProgress) return;
    await _sync(groupId, group);
  }

  onClickDelete(BuildContext context, int groupId) async {
    HapticFeedback.vibrate();
    final group = _persistenceService.get(groupId);
    if (group == null) return;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_getUndoSnackbar(group));
    }
    await _persistenceService.remove(groupId);
  }

  setSearchQuery(String query) {
    syncGroupsNotifier.searchQuery = query;
  }

  _retryInProgressSyncs() {
    _persistenceService
        .getAll()
        .filterValues((group) => group.status == SyncStatus.inProgress)
        .forEach(_sync);
  }

  _sync(int id, SyncGroup group) async {
    group = group.copyWith(syncCount: group.syncCount + 1);
    await _persistenceService.set(
      id,
      group.copyWith(
        status: SyncStatus.inProgress,
        lastStatus:
            group.status != SyncStatus.inProgress
                ? group.status
                : group.lastStatus,
      ),
    );
    final result = await _syncService.synchronize(group);
    await _persistenceService.set(id, result);
  }

  _getUndoSnackbar(SyncGroup group) => SnackBar(
    content: const Text('Deleting...'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        _persistenceService.add(group);
      },
    ),
  );
}
