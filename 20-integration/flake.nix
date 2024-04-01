{
  description = "integration test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # TODO: understand how/if we can inherit inputs from our flake
    mylocalrepo.url = "git+file:///home/vsiles/test-nix/nix-playground";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = inputs@{ mylocalrepo, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        mylocalrepo.flakeModule
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
