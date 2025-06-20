import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SourceHelpDialog extends StatelessWidget {
  const SourceHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selection help'),
      content: SingleChildScrollView(
        child: Text(
          'Select the location of the folder that you would like to synchronize. Typically you want to choose phone memory in the first step and cloud storage (Google Drive, OneDrive, ...) in the second.',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            context.pop();
          },
        ),
      ],
    );
  }
}
