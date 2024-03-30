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
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        craneLib = crane.lib.${system};
        # manifest-path = ./Cargo.toml;
        # rust-info = pkgs.callPackage ./rust-module.nix  { inherit craneLib manifest-path; };
      in
      {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # checks = {
        #   inherit (rust-info) default;
        # };

        packages.default = pkgs.hello; # rust-info.packages;

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
