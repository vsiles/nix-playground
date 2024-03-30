{craneLib, lib, pkgs, stdenv, system, rustConfiguration } :
# if this project is a workspace, we want to create single packages for
# every members of it so we can build or run them independently
let 
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
  my-rust-project = craneLib.buildPackage {
    pname = rustConfiguration.name;
    version = rustConfiguration.version;
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
  op = name: pickBinary {pkg = my-rust-project.out; bin = name; };
  all-packages =
    lib.lists.foldl (acc: name: acc // {"${name}" = op name; }) {} rustConfiguration.members;
in
  {
    packages = { default = my-rust-project; } // all-packages;
    checks = { inherit my-rust-project; };
  }
