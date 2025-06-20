import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flync/ui/page/storage_form/config/storage_source_ui.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FtpConfigForm extends StatefulWidget {
  const FtpConfigForm({super.key});

  @override
  State<FtpConfigForm> createState() => _FtpConfigFormState();
}

class _FtpConfigFormState extends State<FtpConfigForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormBuilderTextField(
          name: 'hostname',
          validator: FormBuilderValidators.required(),
          decoration: InputDecoration(
            labelText: 'Hostname',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search_outlined),
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(height: formFieldPadding),
        FormBuilderTextField(
          name: 'username',
          validator: FormBuilderValidators.required(),
          decoration: InputDecoration(
            labelText: 'Username',
            suffixIcon: IconButton(
              icon: const Icon(Icons.person_off_outlined),
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(height: formFieldPadding),
        FormBuilderTextField(
          name: 'password',
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(Icons.visibility_outlined),
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(height: formFieldPadding),
        FormBuilderTextField(
          name: 'directory',
          validator: FormBuilderValidators.required(),
          decoration: InputDecoration(
            labelText: 'Folder',
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
