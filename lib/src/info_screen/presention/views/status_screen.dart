import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/media.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../core/res/styles/text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../configs/presention/app/adapter/configs_adapter.dart';
import '../../../home/presentation/views/home_view.dart';

enum Status { loading, success, error, idle, connecting }

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key, this.status, this.message});
  final Status? status;
  final String? message;

  static const path = '/info';

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  late Status _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status ?? Status.idle; 

        

  }

  @override
  Widget build(BuildContext context) {

    ref.listen(connectionAdapterProvider(), (p, next) {
          if(next is ConnectionStateConnecting){
            debugPrint(next.runtimeType.toString());
            setState(() => _status = Status.connecting);
          }else if( next is ConnectionStateConnected){            debugPrint(next.runtimeType.toString());

                        setState(() => _status = Status.success);
            
          }
          else if(next is ConnectionStateError){            debugPrint(next.runtimeType.toString());

                                    setState(() => _status = Status.error);

          }
          else {            debugPrint(next.runtimeType.toString());

                                    setState(() => _status = Status.idle);

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

    ref.listen(configsAdapterProvider(), (p,n){
      if(n is ConfigsLoaded){
        setState(() => _status = Status.success);
      }
      if(n is ConfigsError){
            setState(() => _status = Status.error);

      }
    });
    ref.watch(currentThemeProvider);

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
              Lottie.asset(animations[_status]!),
              const SizedBox(height: 20),
              Text(texts[widget.status]!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (widget.message != null) Text(widget.message!
              ,style: TextStyles.headingBold1.copyWith(
                color: Colours.classicAdabtiveTextColor(context)
              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _floatingActionButton(
        (){
          ref.read(configsAdapterProvider().notifier).getConfigs();
        }
        ,_status == Status.error,)
    );
  }
}

ElevatedButton? _floatingActionButton(void Function()? onPressed,bool isError){
  if(!isError){
    return null;
  }
  return ElevatedButton(onPressed: onPressed, child: const Text('Retry'));
}
