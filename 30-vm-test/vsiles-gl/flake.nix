{
  description = "A Rust simple opengl progra";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      crane,
    }:
    let
      perSystemOutputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          lib = pkgs.lib;
          craneLib = crane.mkLib pkgs;
          src = craneLib.cleanCargoSource ./.;
          buildInputs = [ pkgs.mesa pkgs.libGL ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];
          commonArgs = {
            inherit src;
            strictDeps = true;
            inherit buildInputs;
            nativeBuildInputs = [
              pkgs.pkg-config
              pkgs.mesa.llvmpipeHook
            ];
          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
          vsiles-gl = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

        in
        {
          packages.vsiles-gl = vsiles-gl;
          packages.default = vsiles-gl;
        }
      );
    in
    perSystemOutputs
    // {
      overlays.default = final: prev: {
        vsiles-gl = perSystemOutputs.packages.${final.stdenv.system}.vsiles-gl;
      };
    };
}
