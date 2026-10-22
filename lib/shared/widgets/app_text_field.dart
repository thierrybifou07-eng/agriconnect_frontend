import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/validators.dart';

/// Consistent text field used by every form of the app.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autoFocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final FieldValidator? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscure;
  late final bool _canToggleObscure = widget.obscure;

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent owns the field type: if it asks for a visible or hidden field
    // back, the field follows instead of keeping the state of its first build.
    if (oldWidget.obscure != widget.obscure) {
      _obscure = widget.obscure;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      autofocus: widget.autoFocus,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        suffixIcon: _canToggleObscure
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                // Without this the button is an unnamed dot to a screen reader.
                tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              )
            : null,
      ),
    );
  }
}
