part of 'injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _cacheInit();
  await _v2rayInit();
  await _configsInit();
  await _adMobInit();
  await _ipInit();
  await _perAppProxyInit();
  await _usageQuotaInit();
  await _configEditorInit();
}

Future<void> _configEditorInit() async {
  sl
    ..registerLazySingleton(() => LoadEditableNode(sl()))
    ..registerLazySingleton(() => SaveEditedNode(sl()))
    ..registerLazySingleton(() => BuildShareLink(sl()))
    ..registerLazySingleton<ConfigEditorRepo>(() => ConfigEditorRepoImpl(sl()))
    ..registerLazySingleton<ConfigEditorLocalDatasrc>(
      () => ConfigEditorLocalDatasrcImpl(sl()),
    );
}

Future<void> _usageQuotaInit() async {
  sl
    ..registerLazySingleton(() => GetUsageQuota(sl()))
    ..registerLazySingleton(() => AddCloudUsage(sl()))
    ..registerLazySingleton(() => AddRewardBonus(sl()))
    ..registerLazySingleton(() => FlushCloudUsage(sl()))
    ..registerLazySingleton(() => GetCachedUsageQuota(sl()))
    ..registerLazySingleton<QuotaRepository>(
      () => QuotaRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<UsageQuotaRemoteDatasrc>(
      () => UsageQuotaRemoteDatasrcImpl(sl<Client>(), sl(), sl()),
    )
    ..registerLazySingleton<UsageQuotaLocalDatasrc>(
      () => UsageQuotaLocalDatasrcImpl(sl()),
    )
    ..registerLazySingleton(() => DeviceIdentity(sl()))
    ..registerLazySingleton(() => const FlutterSecureStorage());
}

Future<void> _perAppProxyInit() async {
  sl
    ..registerLazySingleton(() => GetInstalledApp(sl()))
    ..registerLazySingleton<PerAppProxyRepo>(() => PerAppProxyRepoImpl(sl()))
    ..registerLazySingleton<PerAppProxyDatasrc>(
      () => PerAppProxyDatasrcImpl(sl()),
    );
}

Future<void> _ipInit() async {
  sl
    ..registerLazySingleton(() => GetUserCountry(sl()))
    ..registerLazySingleton(() => GetIpInfo(sl()))
    ..registerLazySingleton<IpRepo>(() => IpRepoImpl(sl()))
    ..registerLazySingleton<IpRemoteDatasrc>(() => const IpRemoteDatasrcImpl());
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
    ..registerLazySingleton(() => LoadRewardedAd(sl()))
    ..registerLazySingleton(() => ShowRewardedAd(sl()))
    ..registerLazySingleton<AdmobRepo>(() => AdmobRepoImpl(sl()))
    ..registerLazySingleton<AdmobRemoteDatasrc>(
      () => AdmobRemoteDatasrcImpl(),
    );
}

Future<void> _configsInit() async {
  AppConfig.ensureConfigured();
  final client = Client()
      .setEndpoint(AppConfig.appwriteEndpoint)
      .setProject(AppConfig.appwriteProjectId);

  sl
    ..registerLazySingleton(() => GetConfigs(sl()))
    ..registerLazySingleton(() => GetCachedConfigs(sl()))
    ..registerLazySingleton<ConfigsRepo>(() => ConfigsRepoImpl(sl()))
    ..registerLazySingleton<ConfigsRemoteDatasrc>(
      () => ConfigsRemoteDatasrcImpl(sl()),
    )
    ..registerLazySingleton(() => client);
}

Future<void> _v2rayInit() async {
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  late final V2ray v2ray = V2ray(
    onStatusChanged: (status) {
      if (Cache.instance.isVpnDisconnected) return;
      v2rayStatus.value = status;
    },
  );

  sl
    ..registerLazySingleton(() => Connect(sl()))
    ..registerLazySingleton(() => Disconnect(sl()))
    ..registerLazySingleton(() => InitializeV2ay(sl()))
    ..registerLazySingleton(() => WatchVpnStatus(sl()))
    ..registerLazySingleton(() => GetServiceState(sl()))
    ..registerLazySingleton(() => Ping(sl()))
    ..registerLazySingleton(() => RequestPermission(sl()))
    ..registerLazySingleton<ConnectionRepo>(() => ConnectionRepoImpl(sl()))
    ..registerLazySingleton<ConnectionDatasrc>(
      () =>
          ConnectionDatasrcImpl(sl<V2ray>(), sl<ValueNotifier<V2RayStatus>>()),
    )
    ..registerLazySingleton(() => v2ray)
    ..registerLazySingleton(() => v2rayStatus);
}
