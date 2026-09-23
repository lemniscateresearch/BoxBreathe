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

Before the first Android build, use Android Studio's **SDK Manager** to install **Android SDK Command-line Tools (latest)**, then run `flutter doctor --android-licenses` and accept Google's SDK licenses. These are local Android SDK requirements and are deliberately not accepted automatically.
