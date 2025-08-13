import 'package:flutter/material.dart';
import '../../../../core/navigation/router.dart';
import '../../../../core/utils/common.dart';
import 'base_dialog.dart';

class ErrorDialog {
  static show(String error) {
    final BuildContext context = rootNavigatorKey.currentState!.overlay!.context;

    BaseDialog.show(
      title: getAppLocalizations(context).error,
      body: Text(
        error,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.normal),
      ),
      confirmCallback: (context) {
        Navigator.pop(context);
      },
    );
  }
}
