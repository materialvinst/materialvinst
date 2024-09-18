{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          androidsdk = pkgs.callPackage ./nix/android-sdk.nix {
            androidenv = pkgs.androidenv.override { licenseAccepted = true; };
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
