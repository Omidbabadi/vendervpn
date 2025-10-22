part of 'injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _cacheInit();
  await _v2rayInit();
  await _configsInit();
  await _unityAdsInit();
}

Future<void> _cacheInit() async {
  final pref = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton(() => CacheHelper(sl()))
    ..registerLazySingleton(() => pref);
}

Future<void> _unityAdsInit() async {
  final adService = UnityAdsService();
  sl
    ..registerLazySingleton(() => UnityAdsService())
    ..registerLazySingleton(() => adService);
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
  final v2ray = FlutterV2ray(
    onStatusChanged: (s) {
      status.value = s;
    },
  );
  await v2ray.initializeV2Ray(
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
    ..registerLazySingleton<ConnectionRepo>(() => ConnectionRepoImpl(sl()))
    ..registerLazySingleton<ConnectionDatasrc>(
      () => ConnectionDatasrcImpl(
        sl<FlutterV2ray>(),
        sl<ValueNotifier<V2RayStatus>>(),
      ),
    )
    ..registerLazySingleton(() => v2ray)
    ..registerLazySingleton(() => status);
}
