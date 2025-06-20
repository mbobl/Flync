import 'package:flutter/foundation.dart';
import 'package:flync/service/persistence_service.dart';
import 'package:flync/service/service_locator.dart';

class SyncGroupsCountNotifier extends ValueNotifier<int> {
  final _persistenceService = getIt<PersistenceService>();

  SyncGroupsCountNotifier() : super(0) {
    _initialize();
  }

  _initialize() async {
    _onDataChange();
    _persistenceService.addOnChangeListener(_onDataChange);
  }

  _onDataChange() async {
    value = _persistenceService.count();
  }
}
