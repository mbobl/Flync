import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/storage_form/config/storage_source_ui.dart';
import 'package:flync/ui/page/storage_form/storage_config_page_manager.dart';

class StorageConfigPage extends StatefulWidget {
  final int step;
  final StorageSourceUi selectedSourceUi;

  const StorageConfigPage({
    super.key,
    required this.step,
    required this.selectedSourceUi,
  });

  @override
  State<StorageConfigPage> createState() => _StorageConfigPageState();
}

class _StorageConfigPageState extends State<StorageConfigPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final manager = getIt<StorageConfigPageManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton(
              onPressed: () => manager.submit(_formKey, widget.step),
              child: Text(
                manager.canSave(widget.step) ? 'Save' : 'Next',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: manager.validationInProgressNotifier,
              builder:
                  (context, validationInProgress, child) =>
                      validationInProgress
                          ? LinearProgressIndicator()
                          : SizedBox(
                            height: 4,
                          ), //TODO: This is visible on scroll
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        Icon(
                          widget.selectedSourceUi.iconData,
                          opticalSize: 40,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        AutoSizeText(
                          widget.selectedSourceUi.description,
                          style: Theme.of(context).textTheme.headlineMedium,
                          maxLines: 1,
                        ),
                        SizedBox(height: 32),
                        Visibility(
                          maintainSize: false,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: false,
                          child: FormBuilderTextField(
                            name: 'source',
                            initialValue: widget.selectedSourceUi.source.name,
                          ),
                        ),
                        widget.selectedSourceUi.formConstructor(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
