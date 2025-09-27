part of 'injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _cacheInit();
  await _v2rayInit();
  await _configsInit();
}

Future<void> _cacheInit() async {
  final pref = SharedPreferences.getInstance();
  sl
    ..registerLazySingleton(() => CacheHelper(sl()))
    ..registerLazySingleton(() => pref);
}

Future<void> _configsInit() async {
  final client = Client().setProject('68cfc3210015c46501bd').setSession('');
  print(client.endPoint);

  sl
    ..registerLazySingleton(() => GetConfigs(sl()))
    ..registerLazySingleton<ConfigsRepo>(() => ConfigsRepoImpl(sl()))
    ..registerLazySingleton<ConfigsRemoteDatasrc>(
      () => ConfigsRemoteDatasrcImpl(sl()),
    )
    ..registerLazySingleton(() => client);
  final list = await GetConfigs(sl()).call();
  print(list);
}

Future<void> _v2rayInit() async {
  final stateController = StreamController<V2RayState>.broadcast();
  final v2ray = FlutterV2ray(
    onStatusChanged: (s) {
      stateController.add(V2RayStateModel.fromV2rayStatus(s));
    },
  );
  sl
    ..registerLazySingleton(() => Connect(sl()))
    ..registerLazySingleton(() => Disconnect(sl()))
    ..registerLazySingleton(() => InitializeV2ay(sl()))
    ..registerLazySingleton(() => GetVpnState(sl()))
    ..registerLazySingleton<ConnectionRepo>(() => ConnectionRepoImpl(sl()))
    ..registerLazySingleton<ConnectionDatasrc>(
      () => ConnectionDatasrcImpl(
        sl<FlutterV2ray>(),
        sl<StreamController<V2RayState>>(),
      ),
    )
    ..registerLazySingleton(() => v2ray)
    ..registerLazySingleton(() => stateController);
}
