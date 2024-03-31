{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
  unwrap = default: x: if x == null then default else x;
in
{
  # VS: Lots of boiler plate if you ask me, but meh
  options.perSystem = mkPerSystemOption ({ config, self', pkgs, ... }: {
    options = {
      # VS: simple option, just for the show
      my-simple-option = mkOption {
        description = "Some toplevel option";
        type = types.int;
      };

      # VS: I introduce `my-options` so that things are clearer when
      # VS: we import the module in a flake using parts.
      # VS: It could be removed and all options would be directly accessible
      # from the `config` VS: input
      my-options = mkOption {
        description = "Sub module just for clarity in the main file";
        type = types.submodule {
          options = {
            # VS: Mandatory path to an existing file
            some-path = mkOption {
              description = "Path to some file";
              type = types.path;
            };
            # VS: Optional int, but must be explicitly set to null or an
            # VS: integer
            some-opt-int0 = mkOption {
              description = "Maybe some integer";
              type = types.nullOr types.int;
            };
            # VS: optional int with null as default value. Can be omitted
            some-opt-int1 = mkOption {
              description = "Maybe some integer";
              type = types.nullOr types.int;
              default = null;
            };
            # VS: same with an optional string
            some-str-with-default0 = mkOption {
              description = "A string, with a default";
              type = types.str;
              default = "meh";
            };
            some-str-with-default1 = mkOption {
              description = "A string, with a default";
              type = types.str;
              default = "foobar";
            };
            # VS: This is like an "output" option: you can't set it
            # VS: but you'll be able to access it from `config.my-options.some-output`
            some-output = mkOption {
              description = "A read-only value, produced by this module";
              readOnly = true;
              type = types.int;
            };
          };

          config = {
            # VS: this is where we set the value of `some-output`
            some-output =
              (unwrap 0 config.my-options.some-opt-int0) +
              (unwrap 0 config.my-options.some-opt-int1) +
              42;
          };
        };
      };
    };
  });
}
