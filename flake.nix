{
  description = "main flake, exposes all modules";

  # TODO: allow for override / overlays. This is all very static for now
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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

  outputs = { flake-parts, ... }: {
    flakeModule = ./flake-module.nix;
  };
}
