{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          pkgs'' = import inputs.nixpkgs {
            inherit system;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };

          };
          androidsdk = pkgs''.callPackage ./nix/android-sdk.nix {
            androidenv = pkgs''.androidenv.override { licenseAccepted = true; };
          };
        in
        {
          devShells.default = pkgs.callPackage ./nix/devShell.nix {
            androidsdk = androidsdk;
          };
        };

      flake = { };
    };
}
