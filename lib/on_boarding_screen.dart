import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vendervpn/home_page.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:vendervpn/services/api_service.dart';
import 'package:vendervpn/widgets/show_snackbar.dart';
import 'package:lottie/lottie.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingAnimation;
  late AnimationController _lottieContorller;
  bool _isLoding = false;
  final Box<ConfigModel> configsBox = Hive.box('configs');

  @override
  void initState() {
    if (configsBox.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
    super.initState();
    _loadingAnimation = AnimationController(vsync: this);
    _loadingAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loadingAnimation.repeat();
      }
    });
    _lottieContorller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 120),
    );
    _lottieContorller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieContorller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _loadingAnimation.dispose();
    _lottieContorller.dispose();
    super.dispose();
  }

  Future<void> _getConfigs() async {
    if (mounted) {
      setState(() {
        _isLoding = !_isLoding;
      });
    }
    final apiService = ApiService();
    try {
      final configs = await apiService.getConfigsList();
      if (configs == null) return;
      if (configs.isEmpty) {
        if (mounted) {
          showSnackBar(
            context,
            true,
            title: AppLocalizations.of(context)!.server_issue,
            message: '0 ${AppLocalizations.of(context)!.founded_servers}',
          );
          setState(() {
            _isLoding = !_isLoding;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      }
      if (mounted) {
        showSnackBar(
          context,
          false,
          title: AppLocalizations.of(context)!.succesful,
          message:
              '${configs.length.toString()} ${AppLocalizations.of(context)!.founded_servers}',
        );
      }
      ref.read(userPrefsProvider.notifier).setDefaultConfig(configs[0]);
      await configsBox.clear();
      await configsBox.addAll(configs);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          true,
          title: AppLocalizations.of(context)!.error,
          message: '$e',
        );

        setState(() {
          _isLoding = !_isLoding;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    //TO-DO: replace with status in controller
    final v2rayState = ref.watch(v2rayControllerProvider);

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: height * .10),
                  SizedBox(
                    child: Lottie.asset(
                      'assets/animations/Animation-8.json',
                      controller: _lottieContorller,
                      onLoaded: (composition) {
                        debugPrint('Loaded: ${composition.duration}');
                        _lottieContorller
                          ..duration = composition.duration
                          ..forward();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('lotte failed with error: $error');
                        return Text('$error');
                      },
                      fit: BoxFit.fill,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: height / 2,
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 190,
                    child: v2rayState.when(
                      data: (v2ray) {
                        return _isLoding
                            ? const LinearProgressIndicator()
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  55,
                                  223,
                                  139,
                                ),
                              ),
                              onPressed: _isLoding ? null : _getConfigs,
                              child:
                                  _isLoding
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        AppLocalizations.of(context)!.next,
                                        style: TextStyle(color: Colors.white),
                                      ),
                            );
                      },
                      error: (e, st) {
                        return Text(AppLocalizations.of(context)!.error);
                      },
                      loading: () {
                        return FilledButton(
                          onPressed: null,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
