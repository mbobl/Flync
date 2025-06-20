import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flync/model/storage_config.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/persistence_service.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/service/sync/sync_service.dart';
import 'package:flync/ui/page/storage_form/validation_error_dialog.dart';
import 'package:go_router/go_router.dart';

class StorageConfigPageManager {
  final validationInProgressNotifier = ValueNotifier<bool>(false);

  final _formResult = <int, StorageConfig>{};
  final PersistenceService _persistenceService = getIt<PersistenceService>();
  final SyncService _syncService = getIt<SyncService>();

  bool canSave(int step) => step >= 2;

  submit(GlobalKey<FormBuilderState> formKey, int step) async {
    final state = formKey.currentState!;
    final context = formKey.currentContext!;
    if (!state.validate()) return;

    final config = _extractFormData(state);
    final proceed = await _showDialogIfInvalid(config, context);
    if (proceed && context.mounted) {
      _finalizeForm(config, context, step, canSave(step));
    }
  }

  localDirectoryPicker(BuildContext context) async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null && context.mounted) {
      FormBuilder.of(context)?.fields['directory']?.didChange(result);
    }
  }

  _finalizeForm(
    StorageConfig config,
    BuildContext context,
    int step,
    bool save,
  ) {
    _formResult[step - 1] =
        config; //TODO: Watch out when implementing infinite syncs, this map needs to be cleared
    if (save) {
      _saveAndSync(
        SyncGroup(
          configs: _formResult.values.toList(),
          status: SyncStatus.inProgress,
          syncCount: 0,
        ),
      );
      context.go('/');
    } else {
      context.push('/storage-source-select/${step + 1}');
    }
  }

  StorageConfig _extractFormData(FormBuilderState formState) {
    final json = formState.fields.map((k, v) => MapEntry(k, v.value)).toMap();
    return StorageConfig.fromJson(json);
  }

  Future<bool> _showDialogIfInvalid(
    StorageConfig config,
    BuildContext context,
  ) async {
    validationInProgressNotifier.value = true;
    try {
      await config.source
          .client(config: config)
          .validate()
          .timeout(Duration(seconds: 5));
      return true;
    } catch (e) {
      final description = _exceptionToDescription(e);
      if (context.mounted) {
        final result = await _showValidationErrorDialog(context, description);
        return result == true;
      }
      return false;
    } finally {
      validationInProgressNotifier.value = false;
    }
  }

  Future<bool?> _showValidationErrorDialog(
    BuildContext context,
    String? description,
  ) => showDialog<bool>(
    context: context,
    builder: (context) => ValidationErrorDialog(errorDescription: description),
  );

  String? _exceptionToDescription(Object e) {
    if (e is PathNotFoundException) {
      return 'The chosen folder does not exist.';
    }
    if (e is TimeoutException) {
      return 'Timeout when trying to access the folder.';
    }
    return null;
  }

  _saveAndSync(SyncGroup group) async {
    int id = await _persistenceService.add(group);
    final result = await _syncService.synchronize(group);
    _persistenceService.set(id, result);
  }
}
