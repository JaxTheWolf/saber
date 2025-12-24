{
  description = "Flutter Stylus Test App";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # This automates the complex Android SDK setup on NixOS
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      android-nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        # Define the Android SDK components we need
        androidSdk = android-nixpkgs.sdk.${system} (
          sdkPkgs: with sdkPkgs; [
            cmdline-tools-latest
            build-tools-35-0-0
            build-tools-36-0-0
            build-tools-34-0-0
            build-tools-31-0-0
            platform-tools
            platforms-android-35
            platforms-android-36
            platforms-android-34
            platforms-android-31
            emulator
            ndk-27-0-12077973
            ndk-28-2-13676358
            cmake-3-22-1
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          # Point environment variables to the Nix store locations
          ANDROID_HOME = "${androidSdk}/share/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/share/android-sdk";
          JAVA_HOME = pkgs.jdk17.home;
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/share/android-sdk/build-tools/35.0.0/aapt2";

          buildInputs = with pkgs; [
            flutter
            jdk17
            androidSdk
          ];

          shellHook = ''
            echo "⚡ Flutter Environment Loaded"
            echo "Android SDK: $ANDROID_HOME"
            echo "Java: $JAVA_HOME"
          '';
        };
      }
    );
}
