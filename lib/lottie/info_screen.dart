import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum Status { loading, success, error, idle }

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.status, this.message});
  final Status status;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final Map<Status, String> animations = {
      Status.loading: 'assets/loading.json',
      Status.success: 'assets/success.json',
      Status.error: 'assets/error.json',
      Status.idle: 'assets/idle.json',
    };
    // TODO: localize these texts
    final Map<Status, String> texts = {
      Status.loading: 'Loading',
      Status.success: 'Success',
      Status.error: 'Error',
      Status.idle: 'Idle',
    };

    return Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(24)
    ,child: Column(
      mainAxisAlignment: MainAxisAlignment.center,children: [
        Lottie.asset(animations[status]!,
        width: 200,height: 200,
        repeat: status == Status.loading
        ),const SizedBox(
          height:20
        ),Text(texts[status]!,
        textAlign: TextAlign.center,
        )
      ],
    )),),);
  }
}
