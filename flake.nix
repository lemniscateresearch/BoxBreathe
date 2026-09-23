{
  description = "BoxBreathe Flutter development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          # `flutter test` builds native assets for macOS (for example
          # package:objective_c) and signs them. The Nix xcrun cannot do
          # this: Dart build hooks run without DEVELOPER_DIR, so it cannot
          # find the SDK, and it does not know `codesign`. Use the system
          # xcrun with the Command Line Tools instead, when it exists.
          xcrunShim = pkgs.writeShellScriptBin "xcrun" ''
            if [ -x /usr/bin/xcrun ]; then
              unset DEVELOPER_DIR
              exec /usr/bin/xcrun "$@"
            fi
            exec ${pkgs.xcbuild}/bin/xcrun "$@"
          '';
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.flutter
              pkgs.jdk17
              pkgs.git
            ];

            JAVA_HOME = pkgs.jdk17.home;

            shellHook = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
              export PATH="${xcrunShim}/bin:$PATH"
            '' + ''
              flutter config --no-analytics >/dev/null
              echo "BoxBreathe environment ready. Android SDK: Android Studio-managed. Run: flutter doctor"
            '';
          };
        });
    };
}
