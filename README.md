# BoxBreathe

A calm breathing companion for guided breathing sessions. The app supports three methods: box breathing, figure-eight breathing, and triangle breathing. The user follows a dot that travels along the chosen shape. The project targets Android first and includes an iOS runner for a future port.

## Dedication

This project is dedicated to my wonderful grandma, who has been with me through it all.

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

CI ([`.github/workflows/ci.yml`](./.github/workflows/ci.yml)) checks the formatting, runs the analyzer and runs the tests on each push and pull request. CI does not run the golden image tests, because the images are made on macOS. Run them locally with `nix develop --command flutter test --tags golden`.

Before the first Android build, use Android Studio's **SDK Manager** to install **Android SDK Command-line Tools (latest)**, then run `flutter doctor --android-licenses` and accept Google's SDK licenses. These are local Android SDK requirements and are deliberately not accepted automatically.

### Release builds

Android installs an update only when the update has the same signature as the installed app. Thus, sign every release with the same upload key.

1. Create a keystore one time. Keep it outside the repository and make a backup of it. If you lose it, you cannot update an installed app:

   ```sh
   nix develop --command keytool -genkey -v -keystore ~/keys/boxbreathe-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` with these lines. Git ignores this file. Do not commit it:

   ```properties
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/Users/<you>/keys/boxbreathe-upload.jks
   ```

3. Build and install the release APK:

   ```sh
   nix develop --command flutter build apk --release
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

If `android/key.properties` does not exist, the release build uses the debug key. Gradle writes a warning, but Flutter shows it only with `-v`. Do not install that build on a phone that you want to update later.
