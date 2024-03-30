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
    craneLib = inputs.crane.lib.${system};
    # from https://crane.dev/examples/quick-start.html
    basic-info = {
      src = craneLib.cleanCargoSource (craneLib.path ./.);
      # This will silence a lot of warnings for virtual workspaces that
      # usually don't have name and version
      pname = config.rustConfiguration.name;
      version = config.rustConfiguration.version;
    };
    # Common arguments can be set here to avoid repeating them later
    commonArgs = basic-info // {
      strictDeps = true;

      buildInputs = [
        # Add additional build inputs here
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        # Additional darwin specific inputs can be set here
      pkgs.libiconv
      ];

      # Additional environment variables can be set directly
      # MY_CUSTOM_VAR = "some value";
    };

    # Build *just* the cargo dependencies, so we can reuse
    # all of that work (e.g. via cachix) when running in CI
    cargoArtifacts = craneLib.buildDepsOnly commonArgs;

    my-rust-project = craneLib.buildPackage (commonArgs // {
      inherit cargoArtifacts;
    } // {
      # just to show how to do that
      cargoExtraArgs = "-v";
    });

    all-packages =
      lib.lists.foldl (acc: name: acc // {"${name}" = op name; })
      {} config.rustConfiguration.members;
    default =
      if config.rustConfiguration.is-workspace then (
        # TODO: check if manifest.workspace.package is set or not
        if config.rustConfiguration.default-package == null 
        then builtins.throw "workspace mut set the default-package option"
        else all-packages.${config.rustConfiguration.default-package}
      ) else my-rust-project;
  in
  {
    packages = { inherit default; } // all-packages;
    checks = {
      # Build the crate as part of `nix flake check` for convenience
      inherit my-rust-project;

      # Run clippy (and deny all warnings) on the crate source,
      # again, reusing the dependency artifacts from above.
      #
      # Note that this is done as a separate derivation so that
      # we can block the CI if there are issues here, but not
      # prevent downstream consumers from building our crate by itself.
      my-crate-clippy = craneLib.cargoClippy (commonArgs // {
        inherit cargoArtifacts;
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
      });

      my-crate-doc = craneLib.cargoDoc (commonArgs // {
        inherit cargoArtifacts;
      });

      my-crate-fmt = craneLib.cargoFmt basic-info;

      my-crate-audit = craneLib.cargoAudit (basic-info // {
        # Use inputs, not inputs' as this is not a flake
        advisory-db = inputs.advisory-db;
      });

      my-crate-deny = craneLib.cargoDeny basic-info;

      # TODO: learn about cargo-nextest
      # Run tests with cargo-nextest
      # Consider setting `doCheck = false` on `my-crate` if you do not want
      # the tests to run twice
      my-crate-nextest = craneLib.cargoNextest (commonArgs // {
        inherit cargoArtifacts;
        partitions = 1;
        partitionType = "count";
      });
    };
  });
}
