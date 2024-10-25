{
  description = "A Rust server with Axum and a curl script";

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
          buildInputs = [ pkgs.openssl ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];
          commonArgs = {
            inherit src;
            strictDeps = true;
            inherit buildInputs;

          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
          svc = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

        in
        {
          packages.svc = svc;
          packages.default = svc;

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
    in
    perSystemOutputs
    // {
      overlays.default = final: prev: {
        svc = perSystemOutputs.packages.${final.stdenv.system}.svc;
        test_command = perSystemOutputs.packages.${final.stdenv.system}.test_command;
      };
    };
}
