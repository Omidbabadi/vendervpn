import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

import '../../../../core/res/media.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../l10n/app_localizations.dart';

enum Status { loading, success, error, idle, connecting }

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key, this.status, this.message});
  final Status? status;
  final String? message;

  static const path = '/info';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectionAdapterProvider(), (p, next) {
      if (next is ConnectionStateConnected) {
        context.pop();
        
      } else if(next is ConnectionStateError) {
        
      }
    });
    final Map<Status, String> animations = {
      Status.loading: Media.loadingAnimation,
      Status.success: Media.success,
      Status.error: Media.errorAnimation,
      Status.connecting: Media.connectionAnimation,
      Status.idle: Media.success,
    };
    // TODO: localize these texts
    final Map<Status, String> texts = {
      Status.loading: 'loading',
      Status.success: AppLocalizations.of(context)!.succesful,
      Status.error: AppLocalizations.of(context)!.error,
      Status.connecting: 'connecting',
      Status.idle: 'idle',
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filled(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colours.darkThemePrimaryTextColor,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              switch (status) {
                Status.loading => Lottie.asset(animations[Status.loading]!),
                Status.success => Lottie.asset(animations[Status.success]!),
                Status.error => Lottie.asset(animations[Status.error]!),
                null => Lottie.asset(animations[Status.error]!),
                Status.idle => Lottie.asset(animations[Status.idle]!),
                Status.connecting => Lottie.asset(
                  animations[Status.connecting]!,
                ),
              },
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
