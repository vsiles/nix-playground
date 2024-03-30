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
  options.perSystem = mkPerSystemOption ({ config, self', pkgs, ... }: {
    options = {
      my-options = mkOption {
        description = "Sub module just for clarity in the main file";
        type = types.submodule {
          options = {
            some-path = mkOption {
              description = "Path to some file";
              type = types.path;
            };
            some-opt-int0 = mkOption {
              description = "Maybe some integer";
              type = types.nullOr types.int;
            };
            some-opt-int1 = mkOption {
              description = "Maybe some integer";
              type = types.nullOr types.int;
              default = null;
            };
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
            some-output = mkOption {
              description = "A read-only value, produced by this module";
              readOnly = true;
              type = types.int;
            };
          };

          config = {
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
