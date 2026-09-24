# BoxBreathe

A calm breathing companion for guided breathing sessions. The app supports three methods: box breathing, figure-eight breathing, and triangle breathing. The user follows a dot that travels along the chosen shape. The project targets Android and the web, and includes an iOS runner for a future port.

Open the web version at <https://lemniscateresearch.github.io/BoxBreathe/>.

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

Each CI run also builds an APK for arm64 phones and keeps it for 3 days in the **Artifacts** section of the run page. CI signs this APK with the debug key, so use it for tests only. It cannot update an install that has the real upload key.

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

## Web version

The web version keeps the settings and sequences in the local storage of the browser only. It has no accounts and no analytics, and it sends no data to a server. The site gets all its files, including the CanvasKit renderer, from its own address.

To build and try the web version locally:

```sh
nix develop --command flutter build web --release --no-web-resources-cdn
python3 -m http.server --directory build/web 8000
```

To examine the site that CI builds, download the `github-pages` artifact from the CI run. It contains `artifact.tar`. CI builds the site for the address `/BoxBreathe/`, so put the files in a `BoxBreathe` folder:

```sh
mkdir -p ~/pages-preview/BoxBreathe
tar -xf artifact.tar -C ~/pages-preview/BoxBreathe
python3 -m http.server 8000 --directory ~/pages-preview
```

Then open <http://localhost:8000/BoxBreathe/>. If you serve the files from the root, the browser cannot find them and shows a blank page.

Browsers play sound only after the user touches the page, so the music and the cues start when the user taps **Start session**.

CI builds the site on each push and pull request. A push to `main` publishes the site to GitHub Pages when the repository variable `DEPLOY_WEB` is `true`.

## License

The code is released under the [MIT License](./LICENSE). The music in `assets/music/` is CC0. See [CREDITS.md](./CREDITS.md).
