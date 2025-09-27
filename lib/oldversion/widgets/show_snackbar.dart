import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

showSnackBar(
  BuildContext context,
  bool isError, {
  required String title,
  required String message,
}) {
  toastification.dismissAll();
  toastification.show(
    context: context,
    title: Text(title),
    style: ToastificationStyle.fillColored,
    type: !isError ? ToastificationType.success : ToastificationType.error,
    description: Text(message),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    borderRadius: BorderRadius.circular(12),
    showProgressBar: true,
    dragToClose: true,
  );
}
