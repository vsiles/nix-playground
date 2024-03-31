{lib, config, ...}:
let inherit (lib) mkOption types; in
{
  options = {
    msg = mkOption {
      type = types.str;
      description = "some string";
    };
    x = mkOption {
      type = types.int;
      description = "some int";
    };
    y = mkOption {
      type = types.int;
      description = "some int";
    };
    z = mkOption {
      type = types.int;
      description = "some int we'll return";
      readOnly = true;
    };
  };

  config = {
    z = builtins.trace config.msg (config.x + config.y);
  };
}
