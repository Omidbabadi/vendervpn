import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/media.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../core/res/styles/text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../configs/presention/app/adapter/configs_adapter.dart';
import '../../../home/presentation/views/home_view.dart';
import 'utils/status_utils.dart';

enum Status { loading, success, error, idle, connecting }

//TODO: make this code cleaner

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key, this.status});
  final StatusUtils? status;

  static const path = '/info';

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
   final ValueNotifier<StatusUtils> _statusNotifier =ValueNotifier<StatusUtils>(
           StatusUtils('connection', Status.connecting,),

   ) ;
  late StatusUtils _status;
  bool showBackButton = false;

  @override
  void initState() {
    super.initState();
  
  }

  @override
  Widget build(BuildContext context) {
    final configsState = ref.watch(configsAdapterProvider());
    // TODO: localize these texts
    final Map<Status, String> texts = {
      Status.loading: 'loading',
      Status.success: AppLocalizations.of(context)!.succesful,
      Status.error: AppLocalizations.of(context)!.error,
      Status.connecting: 'connecting',
      Status.idle: 'idle',
    };

    ref.listen(connectionAdapterProvider(), (p, next) {
      if (next is ConnectionStateConnecting) {
        _statusNotifier.value = StatusUtils((texts[Status.connecting] as String),Status.connecting)..showBackButton = false;
        
      } else if (next is ConnectionStateConnected) {
        debugPrint(next.runtimeType.toString());
        _statusNotifier.value = StatusUtils(
            texts[Status.success] as String,
            Status.success,
          )..showBackButton = true;

      } else if (next is ConnectionStateError) {
                _statusNotifier.value = StatusUtils(
            texts[Status.error] as String,
            Status.error,
          )..showBackButton = true;
      } else {
                _statusNotifier.value = StatusUtils(
            texts[Status.success] as String,
            Status.success,
          )..showBackButton = true;
      }
    });

    final Map<Status, String> animations = {
      Status.loading: Media.loadingAnimation,
      Status.success: Media.success,
      Status.error: Media.errorAnimation,
      Status.connecting: Media.connectionAnimation,
      Status.idle: Media.success,
    };

    ref.listen(configsAdapterProvider(), (p, n) {
      if (n is ConfigsLoaded) {
        context.go(HomeView.path);
      }
      if (n is ConfigsError) {
                _statusNotifier.value = StatusUtils(
            n.message,
            Status.error,
          )..showBackButton = false;
      }
    });
    ref.watch(currentThemeProvider);
    final connectedConfig = ref.watch(currentConfigProvider);
    return ValueListenableBuilder<StatusUtils>(
      valueListenable: _statusNotifier,
      builder: (context,status,_) {
        return Scaffold(
          appBar: AppBar(
            leading:
                (status.showBackButton || configsState is ConfigsError)
                    ? IconButton.filled(
                      onPressed: () {
                        context.go(HomeView.path);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colours.darkThemePrimaryTextColor,
                      ),
                    )
                    : null,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Lottie.asset(animations[status.status]!),
                  const SizedBox(height: 20),
                  Text(
                    status.message,
                    style: TextStyles.headingBold1.adaptiveColor(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (status.status == Status.success)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Server: ',
                                style: TextStyles.headingSemiBold1.adaptiveColor(
                                  context,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' ${connectedConfig!.remark}',
                                    style: TextStyles.paragraphRegular.copyWith(
                                      color: CoreUtils.adabtiveColor(
                                        context,
                                        lightModeColor: Colours.onBlackColor,
                                        darkModeColor: Colours.onWightColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'IP: ',
                                style: TextStyles.headingSemiBold1.adaptiveColor(
                                  context,
                                ),
        
                                children: [
                                  TextSpan(
                                    text: ' ${connectedConfig.address}',
                                    style: TextStyles.paragraphRegular.copyWith(
                                      color: CoreUtils.adabtiveColor(
                                        context,
                                        lightModeColor: Colours.onBlackColor,
                                        darkModeColor: Colours.onWightColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        CoreUtils.getCountryFlag(connectedConfig.country!),
                      ],
                    ),
                  if (configsState is ConfigsError)
                    ElevatedButton(
                      onPressed: () {
                        ref.read(configsAdapterProvider().notifier).getConfigs();
                      },
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
