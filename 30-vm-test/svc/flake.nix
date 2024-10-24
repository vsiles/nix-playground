{
  description = "A Rust server with Axum and a curl script";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    helpkgs.url = "gitlab:pierre-etienne.meunier/helpkgs/develop?host=gitlab.helsing-dev.ai";
    helpkgs.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      self,
      helpkgs,
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
            helpkgs.overlays.${system}
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

        # Just a test for PE's overlay. We build the same package with a different builder
        packages.svc-pe = pkgs.rustPlatform.buildRustPackage {
          pname = "axum-echo-server";
          version = "0.1.0";
          src = ./.;
          # cargoLock = ./Cargo.lock;
          cargoHash = "sha256-F5/EkZ/s7/fwt4+g9Vfv9Kq16oNt/GIJ/CqdrJ8sSmI=";
          inherit buildInputs;
        };

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
