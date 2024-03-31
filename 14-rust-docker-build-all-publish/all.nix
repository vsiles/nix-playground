{ flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption ({ inputs', config, self', pkgs, system, ... }:
  let
    all-packages = config.rustPackages ++ config.dockerPackages;
  in {
    packages = {
      all = pkgs.symlinkJoin {
        name = "all";
        paths = all-packages;
      };
    };
  });
}
