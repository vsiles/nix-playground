{lib, pkgs, ...}:
let inherit (lib) mkOption types; in
{
  options = {
    # Note: since text already exists in my-module, we can't result the name
    # try replacing text0 with text
    text0 = mkOption {
      type = types.lines;
      description = "some multiline string separated by \n";
    };

    packages1 = mkOption {
      readOnly = true;
      type = types.attrs;
      description = "Packages !";
    };
  };

  config = {
    packages1 = {
      hello1 = pkgs.hello;
    };
  };
}
