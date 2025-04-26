{lib, pkgs, config, ...}:
let inherit (lib) mkOption types; in
{
  options = {
    input = mkOption {
      type = types.int;
      default = 10;
    };
    out = mkOption {
      type = types.int;
      readOnly = true;
    };
  };

  config = {
    out = config.input;
  };
}
