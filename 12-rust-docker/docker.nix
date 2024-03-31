{ lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ inputs', config, self', pkgs, system, ... }: {
    options = {
      dockerConfiguration = mkOption {
        description = "Information about Docker"; 
        type = types.submodule {
          options = {
            app-name = mkOption {
              type = types.str;
              description = "Name of the single app to build an image for";
            };
            # TODO: try to infer it
            app = mkOption {
              type = types.package;
              description = "The single app to build an image for";
            };
          };
        };
      };
    };
    config =
      let
        bin = config.dockerConfiguration.app;
        name = config.dockerConfiguration.app-name;
      in {
        packages.dockerImage = pkgs.dockerTools.buildImage {
          inherit name;
          tag = "latest";
          copyToRoot = [ bin ];
          config = {
            Cmd = [ "${bin}/bin/${name}" ];
          };
        };
    };
  });
}
