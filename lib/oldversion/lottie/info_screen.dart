import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vendervpn/oldversion/enums/lottie_animation_state.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

import '../../core/res/media.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.status, this.message});
  final Status status;
  final String? message;

  static const path = 'info';

  @override
  Widget build(BuildContext context) {
    final Map<Status, String> animations = {
      Status.loading: Media.loadingAnimation,
      Status.success: Media.success,
      Status.error: Media.errorAnimation,
      Status.connecting: Media.connectionAnimation,
    };
    // TODO: localize these texts
    final Map<Status, String> texts = {
      Status.loading: 'loading',
      Status.success: AppLocalizations.of(context)!.succesful,
      Status.error: AppLocalizations.of(context)!.error,
      Status.connecting: 'connecting',
    };

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                animations[status]!,
                width: 200,
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 20),
              Text(texts[status]!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (message != null) Text(message!),
            ],
          ),
        ),
      ),
    );
  }
}
