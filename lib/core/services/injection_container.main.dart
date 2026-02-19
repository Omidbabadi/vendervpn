part of 'injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _cacheInit();
  await _v2rayInit();
  await _configsInit();
  await _adMobInit();
}

Future<void> _cacheInit() async {
  final pref = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton(() => CacheHelper(sl()))
    ..registerLazySingleton(() => pref);
}

Future<void> _adMobInit() async {
  sl
    ..registerLazySingleton(() => Init(sl()))
    ..registerLazySingleton(() => LoadInterstitialAd(sl()))
    ..registerLazySingleton(() => ShowInterstitialAd(sl()))
    ..registerLazySingleton(() => ShowBannerAd(sl()))
    ..registerLazySingleton<AdmobRepo>(() => AdmobRepoImpl(sl()))
    ..registerLazySingleton<AdmobRemoteDatasrc>(
      () => AdmobRemoteDatasrcImpl(null),
    );
}

Future<void> _configsInit() async {
  final client = Client().setProject('68cfc3210015c46501bd').setSession('');

  sl
    ..registerLazySingleton(() => GetConfigs(sl()))
    ..registerLazySingleton<ConfigsRepo>(() => ConfigsRepoImpl(sl()))
    ..registerLazySingleton<ConfigsRemoteDatasrc>(
      () => ConfigsRemoteDatasrcImpl(sl()),
    )
    ..registerLazySingleton(() => client);
}

Future<void> _v2rayInit() async {
  final status = ValueNotifier<V2RayStatus>(V2RayStatus());
  final v2ray = V2ray(
    onStatusChanged: (s) {
      status.value = s;
    },
  );
  await v2ray.initialize(
    notificationIconResourceType: 'mipmap',
    notificationIconResourceName: 'ic_launcher',
  );
  final per = await v2ray.requestPermission();
  if (!per) return;
  sl
    ..registerLazySingleton(() => Connect(sl()))
    ..registerLazySingleton(() => Disconnect(sl()))
    ..registerLazySingleton(() => InitializeV2ay(sl()))
    ..registerLazySingleton(() => GetVpnState(sl()))
    ..registerLazySingleton(() => Ping(sl()))
    ..registerLazySingleton<ConnectionRepo>(() => ConnectionRepoImpl(sl()))
    ..registerLazySingleton<ConnectionDatasrc>(
      () =>
          ConnectionDatasrcImpl(sl<V2ray>(), sl<ValueNotifier<V2RayStatus>>()),
    )
    ..registerLazySingleton(() => v2ray)
    ..registerLazySingleton(() => status);
}
