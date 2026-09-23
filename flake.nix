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
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.flutter
              pkgs.jdk17
              pkgs.git
            ];

            JAVA_HOME = pkgs.jdk17.home;

            shellHook = ''
              flutter config --no-analytics >/dev/null
              echo "BoxBreathe environment ready. Android SDK: Android Studio-managed. Run: flutter doctor"
            '';
          };
        });
    };
}
