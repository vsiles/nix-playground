{
  description = "Simple flake-parts project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # VS: Original comments of the flake-parts template.
        # VS: Mostly relates to importing a module from an external flake
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

        # VS: my local mini module
        # VS: READ THIS FILE FIRST
        ./my-option.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # VS: toplevel options are weird, they lack scope
        my-simple-option = 1664;

        # VS: this is where we set the input options of our simple module.
        # VS: modules will provide type checking (try to change 10 into "10")
        # VS: and exhaustivity (try removing some of them)
        my-options.some-path = ./some-file;
        my-options.some-opt-int0 = 10;
        my-options.some-str-with-default1 = "some string value";

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        # VS: simple usage of an "output" that I just as debug
        packages.default = builtins.trace (toString config.my-options.some-output) pkgs.hello;
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
