{ lib, inputs, crane, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption ({ inputs', config, self', pkgs, system, ... }:
  let
    lib = pkgs.lib;
    stdenv = pkgs.stdenv;
    craneLib = inputs.crane.lib.${system};

    my-rust-project = craneLib.buildPackage {
      pname = config.rustConfiguration.name;
      version = config.rustConfiguration.version;
      src = craneLib.cleanCargoSource (craneLib.path ./.);
      strictDeps = true;
      # just to show how to do that
      cargoExtraArgs = "-v";

      buildInputs = [
        # Add additional build inputs here
      ] ++ lib.optionals stdenv.isDarwin [
        # Additional darwin specific inputs can be set here
        pkgs.libiconv
      ];
    };
    # When crane builds a workspace, it creates a single package that builds
    # everything. But we might want to expose each single bin/lib of the
    # workspace anyway, so we can build or run them independently
    pickBinary = { pkg, bin }:
      stdenv.mkDerivation {
        inherit system;
        name = bin;

        dontUnpack = true;

        installPhase = ''
        mkdir -p $out/bin
        cp -a ${pkg}/bin/${bin} $out/bin/${bin}
        '';
    };
    op = name: pickBinary {pkg = my-rust-project.out; bin = name; };
    all-packages =
      lib.lists.foldl (acc: name: acc // {"${name}" = op name; })
      {} config.rustConfiguration.members;
  in
  {
    packages = { default = my-rust-project; } // all-packages;
    checks = { inherit my-rust-project; };
  });
}
