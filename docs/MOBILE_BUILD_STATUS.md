# Mobile build status

## Verified locally

- Flutter static analysis passes.
- The Dart test suite passes.
- `app-debug.apk` was built for Android with application id
  `online.aldacareer.polymarketevdesk` and version `0.2.0+2`.
- The app includes network and Android 13+ notification permissions.
- The iOS Runner project, bundle identifiers, and network transport policy are
  included in the repository.

## Android distribution

The debug APK is intended for manual device testing only. It is signed with the
Android debug key and is not a Play Store artifact.

For a production Android release, create a local upload keystore, copy
`android/key.properties.example` to `android/key.properties`, fill in the local
credential values, then build an AAB:

```powershell
keytool -genkeypair -v -keystore polymarket-ev-desk-upload.jks -alias polymarket-ev-desk -keyalg RSA -keysize 2048 -validity 10000
Copy-Item android/key.properties.example android/key.properties
flutter build appbundle --release
```

`android/key.properties` and keystores are ignored by Git.

## iOS distribution

Building an IPA, provisioning a device, and submitting to TestFlight require a
macOS machine with Xcode and an Apple Developer team. The Flutter and iOS source
is ready to open in Xcode; signing credentials are intentionally not stored in
this repository.

## Trading boundary

The mobile client supports market data, analysis, order-book execution estimates,
and paper trades. Real orders must be submitted through a protected backend that
holds no user private key and requests signatures from the user's wallet. See
`MOBILE_EXECUTION_ARCHITECTURE.md` for the required API boundary.
