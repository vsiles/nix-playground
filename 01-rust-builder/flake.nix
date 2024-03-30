{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = inputs@{ crane, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./manifest.nix
        ./rust.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        craneLib = crane.lib.${system};
      in
      {
        rustConfiguration = {
          manifest-path = ./Cargo.toml;
          workspace-name = "my-trivial-project";
          workspace-version = "1.0.0";
        };

        # packages & checks are coming from the rust.nix module !
        # (see app_b for a check)

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
