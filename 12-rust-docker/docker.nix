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
            image-name = mkOption {
              type = types.nullOr types.str;
              description = "Name of the image, if it needs to be different from the app name";
              default = null;
            };
          };
        };
      };
    };
    # TODO: support tag :)
    config =
      let buildDocker = {app-name, image-name, app} :
        let final-image-name = if image-name == null then app-name else image-name; in
        pkgs.dockerTools.buildImage {
          name = final-image-name;
          tag = "latest";
          copyToRoot = [ app ];
          config = {
            Cmd = [ "${app}/bin/${app-name}" ];
          };
      };
      inherit (config.dockerConfiguration) app-name image-name;
      in {
        packages.dockerImage = buildDocker {
          inherit app-name image-name;
          app = if builtins.hasAttr app-name config.packages then
            config.packages.${app-name}
            else builtins.throw "Can't find application ${app-name}";
        };
      };
  });
}
