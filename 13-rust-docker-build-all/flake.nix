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
        ./docker.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      {
        rustConfiguration = {
          manifest-path = ./Cargo.toml;
          workspace-name = "my-trivial-project";
          # there's a default value for it ;)
          # workspace-version = "1.0.0";
          default-package = "app_a";
        };
        dockerConfiguration.packages = [
            { app-name = "app_a"; }
            { image-name = "TheB"; app-name = "app_b"; }
        ];

        devShells = {
          default = pkgs.lib.mkForce (pkgs.mkShell {
            inputsFrom = [ config.devShells.rust ];
            buildInputs = [ pkgs.tree ];
          });
        };
      };
    };
}
