
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:vendervpn/home_page.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/riverpod/providers.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_)async{
          await _connectVpn();
          await _showUnityAds();
          if(mounted && !_isLoading ){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyHomePage() ));
          }
        }
        
    );
  }
  Future<void> _connectVpn() async {

    final v2rayController = ref.read(v2rayControllerProvider.notifier);
    await v2rayController.build();
    final link = 'ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpWZVZzUmpQWEpoWE41Y2dkYWNERTZS@5.78.58.33:13123/?outline=1#omid-Family';
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);

    final config = ConfigModel(
      importedFrom: 'c',
      id: const Uuid().v4(),
      configjson: v2rayURL.getFullConfiguration(),
      remark: v2rayURL.remark,
      port: v2rayURL.port,
      address: v2rayURL.address,
      uri: v2rayURL.url,
      dateAdded: DateTime.now().toIso8601String(),
    );
    await v2rayController.connect(config: config);
    debugPrint('VPN Connected');
  }
  Future<void> _showUnityAds()async{
    UnityAds.init(
        gameId: '5867671',
        firebaseTestLabMode: FirebaseTestLabMode.disableAds,
        onComplete: () => {
          debugPrint("Initialization Completed")
        },onFailed: (error,message){
      debugPrint('Initialization Failed: $error : $message');
    });
    final isisInitialized = await UnityAds.isInitialized();
    debugPrint(isisInitialized.toString());
    if(isisInitialized){
      await UnityAds.showVideoAd(placementId: 'Interstitial_Android',
      onComplete: (_) {
        debugPrint('ad loaded');
        setState(() {
          _isLoading = false;
        });
      },
        onFailed: (placemenId,error,message)=> debugPrint('Ad Failed: $error: $message')
      );
    }else{
      debugPrint('Ad not reade');
    }

  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),),
    );
  }
}
