import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/common.dart';
import '../features/dialogs/hero_dialog_source.dart';
import '../features/dialogs/information_hero_dialog.dart';
import 'custom_icon_button.dart';

class EditText extends StatefulWidget {
  final Widget? leftIcon;
  final bool isPassword;
  final bool autofocus;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final String? hint;
  final String? errorText;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool isMultiLine;
  final TextInputAction textInputAction;

  const EditText({
    super.key,
    this.leftIcon,
    this.focusNode,
    this.isPassword = false,
    this.autofocus = true,
    this.isMultiLine = false,
    this.controller,
    this.textInputType,
    this.hint,
    this.errorText,
    this.onEditingComplete,
    this.onChanged,
    this.textInputAction = TextInputAction.go,
  });

  @override
  State<EditText> createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  bool _isTextVisible = true;
  TextCapitalization textCapitalization = TextCapitalization.none;

  void _setPasswordIcon() {
    setState(() {
      _isTextVisible = !_isTextVisible;
    });
  }

  Widget? _getPrefixIcon() {
    if (widget.errorText == null) {
      return widget.leftIcon;
    }

    // Source code fix implemented for nested hero dialogs:
    // https://github.com/flutter/flutter/issues/29565

    Color? iconColor = Theme.of(context).colorScheme.error;
    String tag = const Uuid().v1();
    return HeroDialogSource(
      tag: tag,
      splashRadius: 24,
      icon: Icon(Icons.info_outline_rounded, color: iconColor),
      heroDialogBuilder: (context) {
        return InformationHeroDialog(
          tag: tag,
          title: getAppLocalizations(context).error,
          description: widget.errorText!,
        );
      },
    );
  }

  CustomIconButton? _getPasswordIcon() {
    if (!widget.isPassword) {
      return null;
    }

    Color? iconColor = Theme.of(context).iconTheme.color;
    if (_isTextVisible) {
      return CustomIconButton(
        splashRadius: 24,
        onPressed: _setPasswordIcon,
        icon: Icon(Icons.visibility, color: iconColor),
      );
    } else {
      return CustomIconButton(
        splashRadius: 24,
        onPressed: _setPasswordIcon,
        icon: Icon(Icons.visibility_off, color: iconColor),
      );
    }
  }

  BorderSide _getUnfocusedBorder() {
    if (widget.errorText == null) {
      // Normal (grey) border
      return BorderSide(
        color: Theme.of(context).shadowColor.withAlpha(30),
        width: 1.0,
      );
    } else {
      // Error border
      return BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.isPassword) {
      _isTextVisible = false;
    }

    if (widget.textInputType == TextInputType.text) {
      textCapitalization = TextCapitalization.sentences;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        style: Theme.of(context).textTheme.bodyMedium,
        focusNode: widget.focusNode,
        controller: widget.controller,
        obscureText: !_isTextVisible,
        keyboardType: widget.textInputType,
        onEditingComplete: widget.onEditingComplete,
        onChanged: widget.onChanged,
        enableSuggestions: true,
        autocorrect: true,
        maxLines: widget.isMultiLine ? null : 1,
        autofocus: widget.autofocus,
        textCapitalization: textCapitalization,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          prefixIcon: _getPrefixIcon(),
          suffixIcon: _getPasswordIcon(),
          hintText: widget.hint,
          hintStyle: Theme.of(context).textTheme.displayMedium,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: _getUnfocusedBorder(),
          ),
        ),
      ),
    );
  }
}
