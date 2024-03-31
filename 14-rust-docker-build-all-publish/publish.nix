{ flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption ({ inputs', config, self', pkgs, system, ... }:
  let
    # TODO: make this configurable in case docker or rust is not used
    publish = pkgs.writeShellApplication {
      name = "publish";
      text = ''
        ${config.packages.rust-publish}/bin/rust-publish
        ${config.packages.docker-publish}/bin/docker-publish
      '';
    };
  in {
    packages = {
      inherit publish;
    };
  });
}
