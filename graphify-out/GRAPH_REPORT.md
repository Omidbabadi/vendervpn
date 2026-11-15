# Graph Report - vendervpn  (2026-11-13)

## Corpus Check
- Large corpus: 194 files · ~719,539 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2065 nodes · 2850 edges · 104 communities (82 shown, 22 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 53 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Shared Localization API
- Persian Localization Strings
- English Localization Strings
- Orb Face Widget
- Pubspec Dependencies
- Config Adapter State
- Cache Helper Storage
- VPN Connection Use Cases
- macOS Plugin Registrant
- Local Configs List
- Linux Runner Embedding
- AdMob Adapter State
- App Injection Container
- Platform App Icons
- V2Ray Config Builder
- Color Palette
- App Router Shell
- Per-App Proxy Adapter
- Ad Singleton State
- Config Repository Layer
- Home and Nodes Views
- Connection Repository
- Connect Button UI
- Connect Parameters
- iOS IPA Workflow
- Status Screen View
- Connection Status UI
- Win32 Window Messages
- App Logo and Strings
- AdMob Init Use Case
- Ad Unit Constants
- Bottom Navigation Bar
- Windows Flutter Window
- AdMob Repository
- Per-App Proxy Sheet
- Subscription Cards
- Splash Screen Flow
- Connection Data Source
- AdMob Remote Data
- Locale Provider
- Ad and IP Repos
- QR Scanner Sheet
- BuildContext Extensions
- App Identity Docs
- IP Info Provider
- Riverpod Ad Providers
- Error Exception Types
- Theme Provider
- Win32 Client Area
- Configs List Provider
- Windows Runner Utils
- Banner Ad Provider
- Current Config Provider
- Nodes Import Actions
- Dot Matrix Text
- Failure Types
- Configs Remote Source
- Use Case Contracts
- Settings View
- Web Manifest
- IP Remote Data Source
- Core UI Utilities
- Shared UI Widgets
- Installed Apps Use Case
- Win32 Window Lifecycle
- IP Info Model
- Import Action Card
- App Entry Point
- Result Type Aliases
- Nav Bar Item
- MyApp Locale Wiring
- Riverpod State Types
- Ticker State Mixins
- Dashboard Scaffold Utils
- Load Interstitial Ad
- Per-App Proxy Repo
- Analyzer Options
- Ping Use Case
- Custom Painters
- Subscription List Actions
- Localization Delegates
- iOS Launch Images
- Win32 Point Type
- Win32 Size Type
- Android Main Activity
- Theme Mode Extension
- Bool Extension
- Per-App Proxy State
- Category Icon
- Document Icon
- Power Icon

## God Nodes (most connected - your core abstractions)
1. `_` - 44 edges
2. `Default Flutter logo` - 32 edges
3. `Win32Window` - 27 edges
4. `dependencies` - 26 edges
5. `localConfigsListProvider` - 18 edges
6. `AdmobState` - 17 edges
7. `CacheHelper` - 14 edges
8. `nodesViewUiStateProvider` - 12 edges
9. `FlutterWindow` - 12 edges
10. `AdmobRepo` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Default Flutter logo` --semantically_similar_to--> `Default Flutter logo`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png
- `Default Flutter logo` --semantically_similar_to--> `Default Flutter logo`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png
- `Default Flutter logo` --semantically_similar_to--> `Default Flutter logo`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png
- `Default Flutter logo` --semantically_similar_to--> `Default Flutter logo`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png
- `Default Flutter logo` --semantically_similar_to--> `Default Flutter logo`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Desktop runner identity** — linux_cmakelists_binary_name, linux_cmakelists_application_id, linux_runner_cmakelists_runner_executable, windows_cmakelists_binary_name, windows_runner_cmakelists_runner_executable [INFERRED 0.85]

## Communities (104 total, 22 thin omitted)

### Community 0 - "Shared Localization API"
Cohesion: 0.01
Nodes (164): actions, add_subscription_url, app_language, auto_connect, auto_syncs_subtitle, auto_update_interval, available_nodes, cancel (+156 more)

### Community 1 - "Persian Localization Strings"
Cohesion: 0.01
Nodes (156): actions, add_subscription_url, app_language, auto_connect, auto_syncs_subtitle, auto_update_interval, available_nodes, cancel (+148 more)

### Community 2 - "English Localization Strings"
Cohesion: 0.01
Nodes (156): actions, add_subscription_url, app_language, auto_connect, auto_syncs_subtitle, auto_update_interval, available_nodes, cancel (+148 more)

### Community 3 - "Orb Face Widget"
Cohesion: 0.02
Nodes (83): accentColor, amp, _angryController, angryFactor, angryValue, _applyMoodTransition, _auraController, auraPhase (+75 more)

### Community 4 - "Pubspec Dependencies"
Cohesion: 0.04
Nodes (48): dependencies, appwrite, avatar_glow, countries_world_map, country_flags, cupertino_icons, dartz, equatable (+40 more)

### Community 5 - "Config Adapter State"
Cohesion: 0.06
Nodes (38): _, config, configs, ConfigsAdapterProvider, ConfigsError, ConfigsInitial, ConfigsLoaded, ConfigsLoading (+30 more)

### Community 6 - "Cache Helper Storage"
Cohesion: 0.05
Nodes (40): cacheConfigs, cacheId, cacheIpCountry, cacheIsFirstTimer, cacheLocalConfigs, cacheLocale, cachePerAppProxyApps, cachePerAppProxyEnabled (+32 more)

### Community 7 - "VPN Connection Use Cases"
Cohesion: 0.07
Nodes (33): _, config, ConnectionAdapterProvider, ConnectionState, ConnectionStateConnected, ConnectionStateConnecting, ConnectionStateDisconnected, ConnectionStateError (+25 more)

### Community 8 - "macOS Plugin Registrant"
Cohesion: 0.06
Nodes (21): Cocoa, desktop_webview_window, device_info_plus, Flutter, flutter_web_auth_2, FlutterMacOS, Foundation, AppDelegate (+13 more)

### Community 9 - "Local Configs List"
Cohesion: 0.05
Nodes (40): _autoSyncTimer, build, _cacheHelper, collapsedSubKeys, copyWith, fromMap, id, importFromRawPayload (+32 more)

### Community 10 - "Linux Runner Embedding"
Cohesion: 0.07
Nodes (14): fl_register_plugins(), main(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+6 more)

### Community 11 - "AdMob Adapter State"
Cohesion: 0.11
Nodes (33): _, AdmobAdapterProvider, AdmobError, AdmobInit, AdmobInitialzed, AdmobInitialzing, AdmobState, BannerAdLoaded (+25 more)

### Community 12 - "App Injection Container"
Cohesion: 0.07
Nodes (12): _adMobInit, _cacheInit, client, _configsInit, init, _ipInit, _perAppProxyInit, pref (+4 more)

### Community 13 - "Platform App Icons"
Cohesion: 0.06
Nodes (33): Default Flutter logo, Default Flutter logo, Default Flutter logo, Default Flutter logo, Default Flutter logo, Purple V app mark, Default Flutter logo, Default Flutter logo (+25 more)

### Community 14 - "V2Ray Config Builder"
Cohesion: 0.06
Nodes (31): _, announce, buildFullConfigurationWithHttpInbound, copyWith, download, expire, _extractAnnounceFromBody, extractLinksFromPayload (+23 more)

### Community 15 - "Color Palette"
Cohesion: 0.06
Nodes (29): cardSurface, classicAdabtiveTextColor, Colours, darkBackgroundColor, darkCardSurface, darkThemePrimaryTextColor, lightBackgroundColor, lightCardSurface (+21 more)

### Community 16 - "App Router Shell"
Cohesion: 0.08
Nodes (10): _buildOrbMoodTransitionPage, rootNavigatorKey, router, _activeIndex, _bannerRequested, child, createState, _getThemeIcon (+2 more)

### Community 17 - "Per-App Proxy Adapter"
Cohesion: 0.07
Nodes (27): allApps, build, _cacheHelper, clearSelectedApps, copyWith, fromStorage, _getInstalledApp, isEnabled (+19 more)

### Community 18 - "Ad Singleton State"
Cohesion: 0.07
Nodes (21): _bannerAd, Cache, cacheVpnState, instance, _interstitialAd, _isVpnDisconnected, _map, reset (+13 more)

### Community 19 - "Config Repository Layer"
Cohesion: 0.09
Nodes (13): ConfigsRepoImpl, _datasrc, getConfigs, ConfigsRepo, getConfigs, call, _repo, ipToCountry (+5 more)

### Community 20 - "Home and Nodes Views"
Cohesion: 0.09
Nodes (9): build, path, _connectToFastestServer, path, build, collapsedSubKeys, isConnected, localConfigs (+1 more)

### Community 21 - "Connection Repository"
Cohesion: 0.09
Nodes (18): UsecaseWithOutParamsGeter, Status, connect, connectionStatus, _datasrc, disconnect, initialize, ping (+10 more)

### Community 22 - "Connect Button UI"
Cohesion: 0.10
Nodes (18): pingingNodeIdsProvider, build, isConnected, isConnecting, onTap, build, config, ConfigTile (+10 more)

### Community 23 - "Connect Parameters"
Cohesion: 0.10
Nodes (19): ConnectionRepoImpl, ConnectionRepo, blockedApps, bypassSubnets, call, config, Connect, ConnectionsParams (+11 more)

### Community 24 - "iOS IPA Workflow"
Cohesion: 0.09
Nodes (21): name, runs-on, steps, jobs, build-ios-ipa, name, on, push (+13 more)

### Community 25 - "Status Screen View"
Cohesion: 0.09
Nodes (14): createState, dispose, _dotMatrixHeadline, initState, _moodForStatus, path, _ringController, Status (+6 more)

### Community 26 - "Connection Status UI"
Cohesion: 0.10
Nodes (15): startConnection, stopConnection, build, build, ConnectionStatus, _formatRate, _formatVolume, isConnected (+7 more)

### Community 27 - "Win32 Window Messages"
Cohesion: 0.16
Nodes (6): Win32Window::GetHandle(), Win32Window::Show(), EnableFullDpiSupportIfAvailable(), EnableNonClientDpiScaling, Scale(), Win32Window::Win32Window()

### Community 28 - "App Logo and Strings"
Cohesion: 0.09
Nodes (14): StringExt, AppLogo, build, isDark, paint, shouldRepaint, showText, size (+6 more)

### Community 29 - "AdMob Init Use Case"
Cohesion: 0.12
Nodes (15): UsecaseWithOutParams, AdmobRepoImpl, AdmobRepo, call, Init, _repo, call, LoadRewardedAd (+7 more)

### Community 30 - "Ad Unit Constants"
Cohesion: 0.10
Nodes (19): androidAppOpenAdTest, androidBannerAdIdTest, androidInterstitialVideoAdTest, androidNativeAdTest, androidRewardedAdTest, androidRewardedInterstitialAdTest, Constants, interstialAdUnitId (+11 more)

### Community 31 - "Bottom Navigation Bar"
Cohesion: 0.11
Nodes (11): build, currentIndex, CustomBottomNavBar, onSelect, _toggleTunnel, HomeView, build, ConnectionButton (+3 more)

### Community 32 - "Windows Flutter Window"
Cohesion: 0.11
Nodes (6): FlutterWindow::OnDestroy(), FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_, Win32Window::OnDestroy()

### Community 33 - "AdMob Repository"
Cohesion: 0.11
Nodes (14): init, loadInterstitialAd, loadRewardedAd, _remoteDatasrc, showBannerAd, showInterstitialAd, showRewardedAd, call (+6 more)

### Community 34 - "Per-App Proxy Sheet"
Cohesion: 0.12
Nodes (15): activeColor, app, createState, dispose, icon, isBypass, isSelected, label (+7 more)

### Community 35 - "Subscription Cards"
Cohesion: 0.12
Nodes (13): SubscriptionItem, SubscriptionUserInfo, _formatExpiryText, groupKey, isConnected, isExpanded, l10n, name (+5 more)

### Community 36 - "Splash Screen Flow"
Cohesion: 0.15
Nodes (7): DashboardScreen, _DashboardScreenState, StatusScreen, _StatusScreenState, createState, SplashScreen, _SplashScreenState

### Community 37 - "Connection Data Source"
Cohesion: 0.13
Nodes (11): connect, ConnectionDatasrc, ConnectionDatasrcImpl, connectionStatus, disconnect, initialize, _isInitialized, ping (+3 more)

### Community 38 - "AdMob Remote Data"
Cohesion: 0.13
Nodes (13): AdmobRemoteDatasrc, AdmobRemoteDatasrcImpl, init, _interstitialAd, loadInterstitialAd, loadRewardedAd, maxFailedLoadAttempts, _mobileAds (+5 more)

### Community 39 - "Locale Provider"
Cohesion: 0.14
Nodes (11): CacheHelper, build, _cacheHelper, CurrentLocale, setLocale, _cacheHelper, getInstalledApp, getSelectedApps (+3 more)

### Community 40 - "Ad and IP Repos"
Cohesion: 0.13
Nodes (11): init, loadInterstitialAd, loadRewardedAd, showBannerAd, showInterstitialAd, showRewardedAd, IpRepoImpl, IpRepo (+3 more)

### Community 41 - "QR Scanner Sheet"
Cohesion: 0.13
Nodes (11): build, createState, dispose, _hasPopped, initState, _laserController, _onDetect, paint (+3 more)

### Community 42 - "BuildContext Extensions"
Cohesion: 0.13
Nodes (7): brightness, ContextExt, height, mediaQuery, size, theme, width

### Community 43 - "App Identity Docs"
Cohesion: 0.15
Nodes (15): Android emulator logcat, Force stop vendervpn, com.vender.vendervpn package, Package update retaining data, com.vender.vendervpn, Linux BINARY_NAME vendervpn, GTK, Linux runner executable (+7 more)

### Community 44 - "IP Info Provider"
Cohesion: 0.14
Nodes (14): activeInfo, afterTun, beforeTun, build, _cacheHelper, copyWith, _datasrc, _extractHttpInboundPort (+6 more)

### Community 45 - "Riverpod Ad Providers"
Cohesion: 0.20
Nodes (12): loadedBannerAdProvider, LoadedBannerAd, CurrentConfig, currentConfigProvider, CurrentConfigsList, currentConfigsListProvider, CurrentTheme, currentThemeProvider (+4 more)

### Community 46 - "Error Exception Types"
Cohesion: 0.21
Nodes (9): adError, AdmobException, CacheException, ConnectionException, message, ping, props, ServerException (+1 more)

### Community 47 - "Theme Provider"
Cohesion: 0.21
Nodes (9): _, create, CurrentThemeProvider, debugGetCreateSourceHash, overrideWithValue, runBuild, build, build (+1 more)

### Community 48 - "Win32 Client Area"
Cohesion: 0.19
Nodes (7): FlutterWindow::OnCreate(), Win32Window::GetClientArea(), Win32Window::OnCreate(), Win32Window, child_content_, quit_on_close_, window_handle_

### Community 49 - "Configs List Provider"
Cohesion: 0.23
Nodes (10): _, create, CurrentConfigsListProvider, debugGetCreateSourceHash, overrideWithValue, runBuild, build, build (+2 more)

### Community 50 - "Windows Runner Utils"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 51 - "Banner Ad Provider"
Cohesion: 0.23
Nodes (10): _, create, debugGetCreateSourceHash, LoadedBannerAdProvider, overrideWithValue, runBuild, clearBannerAd, build (+2 more)

### Community 52 - "Current Config Provider"
Cohesion: 0.23
Nodes (11): _, create, CurrentConfigProvider, debugGetCreateSourceHash, overrideWithValue, runBuild, cacheHelper, build (+3 more)

### Community 53 - "Nodes Import Actions"
Cohesion: 0.26
Nodes (13): localConfigsListProvider, nodesViewUiStateProvider, ConfigsAdapter, configsAdapterProvider, _getConfigs, importFromClipboard, build, _importFromClipboard (+5 more)

### Community 54 - "Dot Matrix Text"
Cohesion: 0.15
Nodes (10): activeColor, build, charSpacing, dotSize, dotSpacing, _glyphs, inactiveColor, paint (+2 more)

### Community 55 - "Failure Types"
Cohesion: 0.23
Nodes (9): AdmobFailure, CacheFailure, ConnectionFailure, errorMessage, Failure, message, props, ServerFailure (+1 more)

### Community 56 - "Configs Remote Source"
Cohesion: 0.20
Nodes (4): _client, ConfigsRemoteDatasrc, ConfigsRemoteDatasrcImpl, getConfigs

### Community 58 - "Use Case Contracts"
Cohesion: 0.18
Nodes (8): call, UsecaseWithOutParamsFuture, UsecaseWithOutParamsNotFuture, UsecaseWithParams, ShowBannerAd, Disconnect, Ping, GetUserCountry

### Community 59 - "Settings View"
Cohesion: 0.18
Nodes (7): activeColor, icon, label, onTap, path, selected, _setTheme

### Community 60 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 61 - "IP Remote Data Source"
Cohesion: 0.22
Nodes (7): fetchIpInfo, IpRemoteDatasrc, IpRemoteDatasrcImpl, ipToCountry, _queryCurrentExitIp, _queryIpApiFallback, _queryIpWhoIs

### Community 62 - "Core UI Utilities"
Cohesion: 0.20
Nodes (4): adabtiveColor, CoreUtils, getCountryFlag, showSnackBar

### Community 63 - "Shared UI Widgets"
Cohesion: 0.20
Nodes (9): DotMatrixText, _GlassSatelliteBubble, NavConnectButton, FastestServerCard, _SubscriptionUserInfoBanner, TabPillButton, _AppSelectionTile, _ModeTabButton (+1 more)

### Community 64 - "Installed Apps Use Case"
Cohesion: 0.22
Nodes (7): call, excludeNonLaunchableApps, excludeSystemApps, GetInstalledApp, GetInstalledAppParams, _repo, withIcon

### Community 65 - "Win32 Window Lifecycle"
Cohesion: 0.20
Nodes (4): Win32Window::Destroy(), WindowClassRegistrar, class_registered_, instance_

### Community 66 - "IP Info Model"
Cohesion: 0.22
Nodes (7): city, countryCode, countryName, ip, IpInfo, isTunnel, props

### Community 67 - "Import Action Card"
Cohesion: 0.25
Nodes (6): accent, build, icon, ImportActionCard, label, onTap

### Community 69 - "Result Type Aliases"
Cohesion: 0.25
Nodes (3): DataMap, Result, ResultFuture

### Community 70 - "Nav Bar Item"
Cohesion: 0.25
Nodes (6): build, icon, label, NavBarItem, onTap, selected

### Community 71 - "MyApp Locale Wiring"
Cohesion: 0.29
Nodes (8): currentLocaleProvider, build, MyApp, perAppProxyProvider, build, initState, build, SettingsView

### Community 72 - "Riverpod State Types"
Cohesion: 0.29
Nodes (5): LocalConfigsList, NodesViewUiState, NodesViewUiStateNotifier, PingingNodeIdsNotifier, SubscriptionsList

### Community 73 - "Ticker State Mixins"
Cohesion: 0.29
Nodes (4): OrbFaceWidget, OrbFaceWidgetState, QrScannerSheet, _QrScannerSheetState

### Community 74 - "Dashboard Scaffold Utils"
Cohesion: 0.25
Nodes (4): all, L10n, DashboardUtils, scaffoldKey

### Community 75 - "Load Interstitial Ad"
Cohesion: 0.29
Nodes (6): call, LoadInterstitialAd, LoadInterstitialAdParams, onAdFailed, onAdLoaded, _repo

### Community 76 - "Per-App Proxy Repo"
Cohesion: 0.29
Nodes (5): PerAppProxyRepoImpl, getInstalledApps, getSelectedApps, PerAppProxyRepo, updateSelectedApps

### Community 77 - "Analyzer Options"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 79 - "Custom Painters"
Cohesion: 0.33
Nodes (5): _VenderEmblemPainter, _DotMatrixPainter, _WavyAiTalkingSpherePainter, _SparklinePainter, _QrViewfinderPainter

### Community 80 - "Subscription List Actions"
Cohesion: 0.33
Nodes (6): checkAndRefreshDueSubscriptions, clearAll, refreshSubscription, removeSubscriptionAndNodes, subscriptionsListProvider, NodesView

### Community 81 - "Localization Delegates"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsFa, of

### Community 82 - "iOS Launch Images"
Cohesion: 0.50
Nodes (4): iOS launch image placeholder, iOS launch image placeholder, iOS launch image placeholder, iOS launch screen assets

### Community 83 - "Win32 Point Type"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 84 - "Win32 Size Type"
Cohesion: 0.50
Nodes (3): Size, height, width

## Knowledge Gaps
- **1186 isolated node(s):** `_pref`, `_urlKey`, `_isFirstTimer`, `_themeMode`, `_permissionKey` (+1181 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1452 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **22 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CacheHelper` connect `Locale Provider` to `Splash Screen Flow`, `Config Adapter State`, `Cache Helper Storage`, `VPN Connection Use Cases`, `Local Configs List`, `IP Info Provider`, `V2Ray Config Builder`, `Theme Provider`, `Per-App Proxy Adapter`, `Current Config Provider`, `Configs Remote Source`, `Settings View`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 27 inferred relationships involving `Default Flutter logo` (e.g. with `Default Flutter logo` and `Default Flutter logo`) actually correct?**
  _`Default Flutter logo` has 27 INFERRED edges - model-reasoned connections that need verification._
- **What connects `_pref`, `_urlKey`, `_isFirstTimer` to the rest of the system?**
  _1186 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Shared Localization API` be split into smaller, more focused modules?**
  _Cohesion score 0.011904761904761904 - nodes in this community are weakly interconnected._
- **Why does `_` connect `V2Ray Config Builder` to `Subscription Cards`, `Result Type Aliases`, `Locale Provider`, `Ad Singleton State`, `Connection Repository`, `Ad Unit Constants`, `Configs Remote Source`, `IP Remote Data Source`, `Core UI Utilities`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Should `Persian Localization Strings` be split into smaller, more focused modules?**
  _Cohesion score 0.012658227848101266 - nodes in this community are weakly interconnected._
- **Why does `Config` connect `Config Adapter State` to `Configs Remote Source`, `Connect Button UI`, `VPN Connection Use Cases`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._