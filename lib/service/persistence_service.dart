import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flync/model/sync_group.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class PersistenceService {
  Future<void> initialize();
  void addOnChangeListener(VoidCallback listener);
  Future<int> add(SyncGroup group);
  Future<void> set(int id, SyncGroup group);
  SyncGroup? get(int id);
  Map<int, SyncGroup> getAll();
  Future<void> remove(int id);
  int count();
}

class HivePersistenceService extends PersistenceService {
  late final Box<String> box;

  @override
  initialize() async {
    await Hive.initFlutter();
    box = await Hive.openBox('syncGroups');
  }

  @override
  Future<int> add(SyncGroup group) async {
    await box.add(_serialize(group));
    return count() - 1;
  }

  @override
  void addOnChangeListener(VoidCallback listener) {
    box.listenable().addListener(listener);
  }

  @override
  SyncGroup? get(int id) {
    final result = box.getAt(id);
    return result != null ? _deserialize(result) : null;
  }

  @override
  Map<int, SyncGroup> getAll() {
    final result = box.values.indexed.map(
      (entry) => MapEntry(entry.$1, _deserialize(entry.$2)),
    );
    return Map<int, SyncGroup>.fromEntries(result);
  }

  @override
  int count() {
    return box.length;
  }

  @override
  Future<void> remove(int id) async {
    await box.deleteAt(id);
  }

  @override
  Future<void> set(int id, SyncGroup group) async {
    await box.putAt(id, _serialize(group));
  }

  String _serialize(SyncGroup group) => jsonEncode(group.toJson());
  SyncGroup _deserialize(String json) => SyncGroup.fromJson(jsonDecode(json));
}
