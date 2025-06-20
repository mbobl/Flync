import 'dart:io';

import 'package:flync/model/sync_group.dart';
import 'package:flync/service/sync/synchronization_job.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class SyncService {
  Future<SyncGroup> synchronize(SyncGroup group);
}

class SimpleSyncService extends SyncService {
  @override
  Future<SyncGroup> synchronize(SyncGroup group) async {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage
          .request(); //TODO: Move to a manager
    }

    try {
      await SynchronizationJob(group).synchronize();
      final snapshot = await SynchronizationJob(group).createSnapshot();
      return group.copyWith(
        fileSnapshot: snapshot,
        status: SyncStatus.synchronized,
      );
    } catch (e) {
      return group.copyWith(status: SyncStatus.failure);
    }
  }
}
