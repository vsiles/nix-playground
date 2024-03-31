{lib, pkgs, ...}:
let inherit (lib) mkOption types; in
{
  options = {
    # lines allows multiple declaration of text and they will be merged
    text = mkOption {
      type = types.lines;
      description = "some multiline string separated by \n";
    };

    packages = mkOption {
      readOnly = true;
      type = types.attrs;
      description = "Packages !";
    };
  };

  config = {
    packages = {
      hello0 = pkgs.hello;
    };
  };
}
