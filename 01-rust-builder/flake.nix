{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = inputs@{ crane, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./manifest.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        craneLib = crane.lib.${system};
        rust-info = pkgs.callPackage ./rust-module.nix  {
          inherit craneLib;
          inherit (config) rustConfiguration;
        };
      in
      {
        rustConfiguration = {
          manifest-path = ./Cargo.toml;
          workspace-name = "my-trivial-project";
          workspace-version = "1.0.0";
        };

        # TODO: not sure the checks are correctly defined
        inherit (rust-info) packages checks;

        # TODO: apps
        # apps.default = flake-parts.lib.mkApp {
        #   drv = my-workspace;
        # };

        devShells =
          let
            rust = craneLib.devShell {
              checks = self'.checks;
              packages = [
              ];
            };
          in {
            inherit rust;
            default = rust;
        };
      };
      flake = {
      };
    };
}
