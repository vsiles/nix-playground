{
  description = "A Rust server with Axum and a curl script";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
          ];
        };
        lib = pkgs.lib;
        craneLib = crane.mkLib pkgs;
        src = craneLib.cleanCargoSource ./.;
        buildInputs =
          [
            pkgs.openssl
          ]
          ++ lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
          ];
        commonArgs = {
          inherit src;
          strictDeps = true;
          inherit buildInputs;

        };
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      in
      {
        packages.default = craneLib.buildPackage (
          commonArgs
          // {
            inherit cargoArtifacts;
          }
        );


        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.curl
            pkgs.rustc
            pkgs.cargo
          ];
          shellHook = ''
            echo 'To test the server with curl:'
            echo './test_command.sh'
          '';
        };

        # TODO(vsiles)
        # add checks, ... https://crane.dev/examples/quick-start.html
        packages.test_command = pkgs.writeShellScriptBin "test_command" ''
          curl -X POST -H "Content-Type: application/json" -d '{"message": "Hello, Axum!"}' http://localhost:3000/echo
        '';
      }
    );
}
