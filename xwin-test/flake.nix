{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        xwin = pkgs.callPackage ./xwin.nix { };
        cache = pkgs.stdenv.mkDerivation {
          name = "build-cache";

          # We are creating a fixed-output derivation
          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = "sha256-+vtFhUhAMJi3CyDuHgbBR04/lDWh8hES4DJ/mO5jIBg=";

          
          unpackPhase = "true"; # nothing to unpack
          buildInputs = [ xwin pkgs.cacert ];
          buildPhase = ''
            # Default values from cargo-xwin
            # XWIN_CROSS_COMPILER="clang-cl"
            # XWIN_CACHE_DIR="..."
            # XWIN_ARCH="x86_64"
            # XWIN_VARIANT="desktop"
            # XWIN_VERSION=16
            # XWIN_INCLUDE_DEBUG_LIBS=0
            # XWIN_INCLUDE_DEBUG_SYMBOLS=0

            mkdir -p $out/cache
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            echo "Running xwin splat..."
            xwin --accept-license --log-level info --cache-dir $out/cache splat
            echo "Download successful"
          '';
          meta = {
            description = "Downloads xwin runtime artifacts using xwin splat";
            license = pkgs.lib.licenses.mit;
          };
        };
      in
      {
        packages = {
          inherit cache xwin;
        };
        formatter = pkgs.writeShellApplication {
          name = "fmt";
          text = ''
            ${pkgs.nixfmt-rfc-style}/bin/nixfmt ./*.nix
          '';
        };
      }
    );
}
