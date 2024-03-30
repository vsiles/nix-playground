{craneLib, lib, pkgs, stdenv, system, manifest-path} :
# if this project is a workspace, we want to create single packages for
# every members of it
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
  package = (pkgs.lib.evalModules {
    modules = [
      ./modules/manifest.nix
      { inherit manifest-path; }
    ];
  }).config.package-info;
  my-workspace = craneLib.buildPackage {
    pname = package.name;
    version = package.version;
    src = craneLib.cleanCargoSource (craneLib.path ./.);
    strictDeps = true;
    cargoExtraArgs = "-v";

    buildInputs = [
      # Add additional build inputs here
    ] ++ lib.optionals stdenv.isDarwin [
      # Additional darwin specific inputs can be set here
      pkgs.libiconv
    ];
  };
  op = name: pickBinary {pkg = my-workspace.out; bin = name; };
  all-packages =
    lib.lists.foldl (acc: name: acc // {"${name}" = op name; }) {} package.members;
in
  { packages = {
    default = my-workspace; } // all-packages;
  }
