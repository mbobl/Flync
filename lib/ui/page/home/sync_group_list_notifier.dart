import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/persistence_service.dart';
import 'package:flync/service/service_locator.dart';

class SyncGroupListNotifier extends ValueNotifier<Map<int, SyncGroup>> {
  final _persistenceService = getIt<PersistenceService>();
  var _searchQuery = '';

  set searchQuery(String query) {
    _searchQuery = query;
    _onDataChange();
  }

  SyncGroupListNotifier() : super({}) {
    _initialize();
  }

  _initialize() {
    _onDataChange();
    _persistenceService.addOnChangeListener(_onDataChange);
  }

  _onDataChange() {
    value = _persistenceService.getAll().filterValues(
      (group) => group.configs.any(
        (config) => config.directory?.contains(_searchQuery) ?? false,
      ),
    );
  }
}
