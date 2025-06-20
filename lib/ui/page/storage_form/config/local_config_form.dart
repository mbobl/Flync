import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/storage_form/storage_config_page_manager.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LocalConfigForm extends StatelessWidget {
  const LocalConfigForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'directory',
      validator: FormBuilderValidators.required(),
      decoration: InputDecoration(
        labelText: 'Folder',
        suffixIcon: IconButton(
          icon: const Icon(Icons.folder_outlined),
          onPressed:
              () => getIt<StorageConfigPageManager>().localDirectoryPicker(
                context,
              ),
        ),
      ),
    );
  }
}
