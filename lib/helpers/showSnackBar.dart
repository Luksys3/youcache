import 'package:flutter/material.dart';
import 'package:youcache/enums/snack_bar_type_enum.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarTypeEnum? type,
}) {
  Color? color =
      type == SnackBarTypeEnum.ERROR ? Color(0xffDC2626) : Colors.green[500];

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
    ),
  );
}
