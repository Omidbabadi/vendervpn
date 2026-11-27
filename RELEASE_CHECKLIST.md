# VenderVPN — Google Play first beta release checklist

Package: `com.vender.vendervpn` · Version: `1.0.0-beta.1+1` · Branch: `personal-no-ads` (confirm release branch)

Legend: 🔴 blocker (Play will reject or the build is unsafe) · 🟠 high risk of policy rejection · 🟢 recommended

---

## Phase 0 — Decisions (do first)

- [ ] Decide the release branch: `personal-no-ads` vs `master`. Ads code (AdMob) is still in `personal-no-ads`.
- [ ] Decide the beta track:
  - **Closed testing** (invite list / Google Group). Required first step for **new personal developer accounts**: at least 12 testers opted in for 14 days in a row before you can apply for production.
  - **Open testing** (public opt-in link). Available once the account allows it.
- [ ] Decide whether ads ship in the beta. If they do, the Phase 1 AdMob items are blockers. If not, remove the AdMob SDK and the `AD_ID` permission entirely.
- [ ] Check **Countries/regions** availability in Play Console. Sanctioned regions can't be selected, which matters if Farsi-speaking users are a target audience.

---

## Phase 1 — Code & build fixes (found in repo)

### Signing 🔴
- [ ] `android/app/build.gradle.kts:29` signs release with the **debug key**. Create an upload keystore:
  `keytool -genkey -v -keystore ~/keys/vendervpn-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] Add `android/key.properties` (storePassword, keyPassword, keyAlias, storeFile) and a `release` signingConfig that reads it.
- [ ] Add `key.properties`, `*.jks`, `*.keystore` to `.gitignore`. Back up the keystore and passwords somewhere off the machine.
- [ ] Enroll in **Play App Signing** (default for new apps).

### SDK levels & native libs 🔴
- [ ] Set `targetSdk = 36` explicitly. Right now it comes from `flutter.targetSdkVersion`. compileSdk is already 36. Check the current minimum in Play Console → Policy → Target API level.
- [ ] **16 KB page-size alignment**: Play requires this for apps targeting Android 15+. The V2Ray/Go native libs in `flutter_v2ray_client` (libv2ray / gojni `.so`) must be linked with `-Wl,-z,max-page-size=16384`. To verify, build the AAB and check the App Bundle Explorer in Play Console, or run `zipalign -c -P 16 -v 4` on the APK.
- [ ] Confirm `minSdk` (currently Flutter default) is fine for VpnService and the plugins.

### Dependencies / reproducibility 🔴
- [ ] `pubspec_overrides.yaml` points `flutter_v2ray_client` at `../flutter_v2ray_client` (local path). The release build must not use it. Delete it (or build in a clean clone), then `flutter pub get`.
- [ ] Pin `flutter_v2ray_client` git `ref:` to a **commit SHA or tag**, not `main`.
- [ ] Push the plugin commits the release depends on.

### Manifest & permissions 🟠
- [ ] `android:label="vendervpn"` → `"VenderVPN"`. Better: a string resource, localized en/fa.
- [ ] **`QUERY_ALL_PACKAGES`** is a restricted permission and needs a Play declaration that is often rejected. For the per-app proxy list, replace it with a `<queries>` block for `MAIN`/`LAUNCHER` intents. Also check that `installed_apps` doesn't add it back (look at the merged manifest).
- [ ] **`READ_PHONE_STATE`**: remove unless there's a real use. It's a sensitive permission and has to be justified in Data safety.
- [ ] **`READ_EXTERNAL_STORAGE`** (from the plugin): strip it with `<uses-permission ... tools:node="remove"/>` if unused.
- [ ] `CAMERA` (QR scan): keep. Request it at runtime only when the scanner opens.
- [ ] `POST_NOTIFICATIONS`: request it at runtime on Android 13+ before connecting.
- [ ] Foreground service: the plugin uses `specialUse` with subtype `vpn`. Be ready to fill in the **FGS declaration** in Play Console, possibly with a short video. Consider `systemExempted`, which is the documented type for VPN apps.
- [ ] Review the final merged manifest: `android/app/build/intermediates/merged_manifests/release/...`.

### AdMob (if ads ship) 🔴
- [ ] Real **App IDs**: set `ADMOB_ANDROID_APP_ID` in `android/secrets.properties` (or a CI env var) and `ADMOB_IOS_APP_ID` in `ios/Flutter/Secrets.xcconfig`. Without them, release builds fall back to Google's sample app ID (Gradle prints a warning).
- [ ] Real **ad unit IDs**: fill the `ADMOB_*_ID` keys in `dart_defines.json`. Release builds use them; debug/profile always use Google's sample IDs (`lib/core/config/app_config.dart`). An empty release ID skips that ad.
- [ ] Add the **UMP consent** flow (GDPR/EEA + US states) before calling `MobileAds.initialize`. Then `AdRequest(nonPersonalizedAds: false)` is correct only after consent.
- [ ] Register test devices so you never click your own live ads.
- [ ] Set up `app-ads.txt` on the developer website.

### Appwrite / auth 🟢
- [ ] Register the Android platform `com.vender.vendervpn` in the live Appwrite project (`6b07171100033f5027f4`). The app uses anonymous sessions only, so the stale OAuth callback scheme (`appwrite-callback-68cfc3…`, an old project) is being removed from the manifest and `Info.plist`.
- [ ] Quota function: set `TEST_BONUS_ENABLED` to `false` in the Appwrite console (created as `true` by `functions/quota/tool/provision.mjs`).
- [ ] Check that the production Appwrite endpoint/project are used, with no dev servers or debug keys in the code.

### Release build hygiene 🟢
- [ ] Build: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=dart_defines.json` (the app throws at startup if the Appwrite keys are missing).
- [ ] Keep `build/symbols` + `mapping.txt` per version. Upload the R8 mapping and native debug symbols to Play.
- [ ] Smoke-test the **release** build on a real device. R8 can break things that work in debug: VPN connect/disconnect, subscription import, QR, per-app proxy, ads, Appwrite login, the cloud quota.
- [x] Remove or guard debug logging: all logs go through `appLog` (debug-only).
- [x] `ctashlog1.txt` untracked and git-ignored; unused `assets/` removed.
- [ ] App icon: adaptive icon (foreground + background) and a themed/monochrome icon.
- [ ] Bump `versionCode` (`+N`) for **every** upload. Play rejects reused codes.

### QA 🟢
- [ ] Run `flutter analyze` and `flutter test`. Today only `test/config_editor` and the default widget test exist.
- [ ] Add an Android CI workflow (only `build-ios-ipa.yml` exists) that builds the AAB from a clean checkout.
- [ ] Test matrix: Android 8/10/13/14/15/16, one low-RAM device, Wi-Fi↔mobile switching, Always-on VPN, kill/restart, battery saver, RTL (fa).

---

## Phase 2 — Policy & compliance

- [ ] **Privacy policy** (public URL, also linked in the app). Cover: VPN traffic handling (no logging claims must be true), Appwrite account data, AdMob/advertising ID, camera, installed-apps list, crash data.
- [ ] **VpnService declaration** in Play Console. VPN must be the app's core function. No traffic manipulation for ads, and no data collection without prominent disclosure and consent.
- [ ] **Prominent disclosure** in the app before collecting the installed-apps list, if it's sent anywhere.
- [ ] **Data safety form**: matches the privacy policy and the SDKs (AdMob, Appwrite, Google Play services).
- [ ] **Advertising ID declaration** (you declare `AD_ID`).
- [ ] **Ads declaration**: "Contains ads" yes/no.
- [ ] **Content rating** questionnaire (IARC).
- [ ] **Target audience**: 18+ or 13+, *not* children. Child audiences pull in Families policy and ad restrictions.
- [ ] **App access**: if features need login, give reviewers test credentials and a working server config.
- [ ] Remaining declarations: News, Health, Financial features, Government — all "No".

---

## Phase 3 — Play Console setup

- [ ] Developer account verified (identity + contact info). Developer email and website set.
- [ ] Create the app: name "VenderVPN", default language, App, Free.
- [ ] **Store listing** (en + fa):
  - [ ] Title (≤30 chars), short description (≤80), full description (≤4000). Don't use misleading claims like "unlimited", "100% anonymous", or "fastest".
  - [ ] App icon 512×512 PNG
  - [ ] Feature graphic 1024×500
  - [ ] ≥2 phone screenshots (recommended 4–8), plus 7"/10" tablet screenshots if tablets are supported
  - [ ] Category: Tools. Tags. Contact email.
- [ ] Create the testing track and testers list (email list or Google Group), plus a feedback URL/email.

---

## Phase 4 — Build, upload, review

- [ ] Clean clone → `flutter pub get` → `flutter build appbundle --release ...`
- [ ] Upload the AAB to the closed/open testing track. Read the **pre-launch report** (crashes, accessibility, security warnings).
- [ ] Release notes (en/fa) for `1.0.0-beta.1`.
- [ ] Submit for review. The first review usually takes a few days, and VPN/FGS/permission declarations can add time.
- [ ] Tag the release in git: `v1.0.0-beta.1+1`.

---

## Phase 5 — Beta run

- [ ] Get ≥12 testers opted in and keep them for 14 days (personal accounts).
- [ ] Monitor Android vitals: ANR rate, crash rate (especially the `:RunSoLibV2RayDaemon` process).
- [ ] Collect feedback. Ship fixes as `beta.2+2`, `beta.3+3`, …
- [ ] Production access application: answer the questions about the testing you did.

---

## Suggested plan

| Day | Work |
|-----|------|
| 1 | Phase 0 1 · keystore + release signing · remove override, pin plugin |
| 2 | Manifest/permission cleanup · targetSdk 36 · 16 KB check of native libs |
| 3 | AdMob real IDs + UMP consent (or remove ads) · release-build smoke test |
| 4 | Privacy policy · store assets (icon, feature graphic, screenshots) · listing text en/fa |
| 5 | Play Console declarations (Data safety, VPN, FGS, ads, rating) · upload to closed testing |
| 6–20 | Closed test with ≥12 testers · fix crashes · iterate builds |
