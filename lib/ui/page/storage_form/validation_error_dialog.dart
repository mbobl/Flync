import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ValidationErrorDialog extends StatelessWidget {
  final String? errorDescription;

  const ValidationErrorDialog({super.key, this.errorDescription});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Folder error'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(errorDescription ?? 'Folder unreachable.'),
            Text('Do you want to continue anyway?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            context.pop(false);
          },
        ),
        TextButton(
          child: const Text('Continue'),
          onPressed: () {
            context.pop(true);
          },
        ),
      ],
    );
  }
}
