import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flync/ui/page/storage_form/config/storage_source_ui.dart';
import 'package:flync/ui/page/storage_form/source_help_dialog.dart';
import 'package:go_router/go_router.dart';

class StorageSourceSelectPage extends StatelessWidget {
  final int step;

  _openInfoDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => SourceHelpDialog(),
  );

  _navigateToStorageConfig(BuildContext context, String sourceName) =>
      context.push('/storage-config/$step/$sourceName');

  const StorageSourceSelectPage({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          IconButton(
            onPressed: () => _openInfoDialog(context),
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: AutoSizeText(
                    'Where is the $step. folder?',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: StorageSourceUi.values.length,
                  itemBuilder:
                      (context, index) => InkWell(
                        onTap:
                            () => _navigateToStorageConfig(
                              context,
                              StorageSourceUi.values[index].name,
                            ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ).copyWith(right: 16),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  StorageSourceUi.values[index].iconData,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            Text(
                              StorageSourceUi.values[index].sourceName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                  separatorBuilder: (context, index) => Divider(height: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
