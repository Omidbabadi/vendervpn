import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:vendervpn/home_page.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (configsBox.isNotEmpty) {
        if (mounted) {
          showSnackBar(
            context,
            true,
            title: 'Server Issue',
            message: '0 Servers Found',
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
            title: 'Server Issue',
            message: '0 Servers Found',
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
          title: 'Successful',
          message: '${configs.length.toString()} Servers Found',
        );
      }
      ref.read(userPrefsProvider.notifier).setDefauktConfig(configs[0]);
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
        showSnackBar(context, true, title: 'Error', message: '$e');

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

  Future<void> _connectAndShowAd() async {
    setState(() {
      _isLoding = true;
    });
    final link =
        'ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpWZVZzUmpQWEpoWE41Y2dkYWNERTZS@5.78.58.33:13123/?outline=1';

    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);

    final config = ConfigModel(
      importedFrom: 'server',
      id: const Uuid().v4(),
      configjson: v2rayURL.getFullConfiguration(),
      remark: v2rayURL.remark,
      port: v2rayURL.port,
      address: v2rayURL.address,
      uri: v2rayURL.url,
      dateAdded: DateTime.now().toIso8601String(),
    );
    final v2rayService = ref.read(v2rayControllerProvider.notifier);
    //v2rayService.disconnect();
    //await v2rayService.connect(config: config);

    if (mounted) {
      showSnackBar(
        context,
        false,
        title: 'Loading Servers',
        message: 'Please Wait While We Getting Data From Server',
      );
    }
    await Future.delayed(Duration(seconds: 15));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final v2rayState = ref.watch(v2rayControllerProvider);

    return Scaffold(
      body: Center(
        child: Container(
          // width: 300,
          // height: 450,
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
                      //width: 250,
                      //height: 180,
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
                                      : const Text(
                                        'Next',
                                        style: TextStyle(color: Colors.white),
                                      ),
                            );
                      },
                      error: (e, st) {
                        return const Text('Error');
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
