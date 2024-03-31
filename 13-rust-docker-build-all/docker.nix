{ lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ inputs', config, self', pkgs, system, ... }:
  let
    # TODO: support tag :)
    app-type = types.submodule {
      options = {
        app-name = mkOption {
          type = types.str;
          description = "Name of the app to build an image for";
        };
        image-name = mkOption {
          type = types.nullOr types.str;
          description = "Name of the image, if different from the app name";
          default = null;
        };
      };
    };
in
  {
    options = {
      dockerConfiguration = mkOption {
        description = "Information about Docker"; 
        type = types.submodule {
          options = {
            packages = mkOption {
              type = types.listOf app-type;
              description = "Information about packages to build images for";
            };
          };
        };
      };
    };
    config =
      let buildDocker = {app-name, image-name, app} :
        let final-image-name = if image-name == null then "docker-${app-name}" else image-name; in
        {
          ${final-image-name} = pkgs.dockerTools.buildImage {
            name = final-image-name;
            tag = "latest";
            copyToRoot = [ app ];
            config = {
              Cmd = [ "${app}/bin/${app-name}" ];
            };
          };
      };
      mkImage = {app-name, image-name} :
        buildDocker {
        inherit app-name image-name;
        app = if builtins.hasAttr app-name config.packages then
          config.packages.${app-name}
          else builtins.throw "Can't find application ${app-name}";
      };
      in {
        packages =
          lib.lists.foldl (acc: app-info: acc // (mkImage app-info)) {}
            config.dockerConfiguration.packages;
    };
  });
}
