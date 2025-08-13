import 'package:flutter/material.dart';

import '../../../../core/navigation/router.dart';
import '../../../../core/utils/common.dart';

class BaseDialog {
  static Future<bool> show({
    required String title,
    required Widget body,
    bool dismissible = true,
    String? confirmText,
    Function(BuildContext context)? confirmCallback,
    String? cancelText,
    Function(BuildContext context)? cancelCallback,
  }) async {
    final BuildContext context = rootNavigatorKey.currentState!.overlay!.context;

    List<Widget>? actions = [];
    if (cancelCallback != null) {
      actions.add(Container(
        padding: const EdgeInsets.only(right: 5),
        width: 130,
        height: 40,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            side: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () => cancelCallback(context),
          child: Text(
            cancelText ?? getAppLocalizations(context).cancel,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));
    }
    if (confirmCallback != null) {
      actions.add(Container(
        padding: const EdgeInsets.only(right: 5),
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: const StadiumBorder(),
          ),
          onPressed: () => confirmCallback(context),
          child: Text(
            confirmText ?? getAppLocalizations(context).confirm,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));
    }

    MainAxisAlignment alignment;
    if (actions.length == 1) {
      alignment = MainAxisAlignment.center;
    } else {
      alignment = MainAxisAlignment.spaceBetween;
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return PopScope(
          canPop: dismissible,
          child: Dialog(
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: body,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: alignment,
                      children: actions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }
}
