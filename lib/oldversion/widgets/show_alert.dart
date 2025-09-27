import 'package:flutter/material.dart';

showAlertDialog({
  required BuildContext context,
  List<Widget>? actions,
  Widget? child,
  Widget? title,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(child: child),
        actions: actions,
      );
    },
  );
}
