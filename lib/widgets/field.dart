import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final String label;
  final String name;
  final String? value;
  final String? error;
  final Map<String, String>? errors;
  final String? Function(String)? validator;
  final void Function(String?, String)? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool last;
  final bool autofocus;
  final String? helperText;
  final TextCapitalization textCapitalization;

  Field({
    required this.label,
    required this.name,
    this.error,
    this.value,
    this.errors,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.obscureText = false,
    this.last = true,
    this.autofocus = false,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        errorText: errors?[this.name],
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[600]!,
          ),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return null;
        }

        if (validator != null) {
          return validator!(value);
        }
      },
      textCapitalization: textCapitalization,
      initialValue: value,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSaved: onSaved == null ? null : (value) => onSaved!(value, name),
      onEditingComplete: last ? null : () => FocusScope.of(context).nextFocus(),
    );
  }
}
