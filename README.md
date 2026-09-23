# BoxBreathe

A calm breathing companion for guided box-breathing sessions. The project targets Android first and includes an iOS runner for a future port.

## Development environment

The [Nix flake](./flake.nix) provides the Flutter SDK and Java 17. Android Studio manages the locally installed Android SDK, including its Google license acceptance.

```sh
nix develop
flutter doctor
flutter run
```

To build a debug Android APK:

```sh
nix develop --command flutter build apk --debug
```

The first Flutter command records the Android Studio SDK location in `android/local.properties`. That file is intentionally untracked because its location is machine-specific.

Before the first Android build, use Android Studio's **SDK Manager** to install **Android SDK Command-line Tools (latest)**, then run `flutter doctor --android-licenses` and accept Google's SDK licenses. These are local Android SDK requirements and are deliberately not accepted by this repository or its Nix flake.

## Open in Android Studio

Open the `android` folder in Android Studio to work with the native Android project, or open the repository root to work on the Flutter app. Start an Android emulator or connect a phone, then run `flutter run` from a Nix shell.

## Project layout

- `lib/main.dart` — Flutter application UI and breathing-session logic.
- `android/` — Android runner and Gradle configuration.
- `ios/` — iOS runner; build it later from macOS with Xcode installed.
- `flake.nix` and `flake.lock` — reproducible Flutter/Java development tooling.
