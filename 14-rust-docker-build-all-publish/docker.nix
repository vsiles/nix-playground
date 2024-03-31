{ inputs, lib, flake-parts-lib, ... }:

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
    nix2containerPkgs = inputs.nix2container.packages.${system};
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
      dockerPackages = mkOption {
        description = "List of all the docker packages that are being built";
        type = types.listOf types.package;
        readOnly = true;
      };
    };
    config =
      let buildDocker = {app-name, image-name, app} :
        let
          final-image-name = if image-name == null then "docker-${app-name}" else image-name;
          image = nix2containerPkgs.nix2container.buildImage {
            name = final-image-name;
            config = {
              entrypoint = ["${app}/bin/${app-name}"];
            };
          };
          # nix2container is creating a file, not a directory.
          # Let's make one so that we can link all our outputs easily
          drv = pkgs.stdenv.mkDerivation {
            name = final-image-name;
            # No src
            unpackPhase = "true";
            buildInputs = [
              pkgs.coreutils # For `mkdir`
            ];
            installPhase = ''
            mkdir -p $out/bin
            cp ${image} $out/bin
            '';
          };
        in
        {
          ${final-image-name} = drv;
        };
      mkImage = {app-name, image-name} :
        buildDocker {
          inherit app-name image-name;
          app = if builtins.hasAttr app-name config.packages then
            config.packages.${app-name}
            else builtins.throw "Can't find application ${app-name}";
      };
      docker-packages = lib.lists.foldl (acc: app-info: acc // (mkImage app-info)) {}
            config.dockerConfiguration.packages;
      # Simple dummy script "to do something" when we run publish
      do-publish = app-name: app:
        pkgs.writeShellApplication {
          name = "publish-${app-name}.sh";
          runtimeInputs = [ pkgs.coreutils ];
          # TODO: not working yet: app-name is not the right input here
          text = ''
            hash=$(sha256sum "${app}/bin/${app-name}" | cut -d ' ' -f 1)
            echo "hash for ${app-name}: ''${hash}"
          '';
        };
      publish-drvs = lib.attrsets.mapAttrs'
        (app-name: app: lib.nameValuePair "publish-${app-name}.sh" (do-publish app-name app))
        docker-packages;
      docker-publish = 
        let
          text = lib.attrsets.foldlAttrs (acc: script-name: app: acc + "\n${app}/bin/${script-name}") "" publish-drvs;
        in
        pkgs.writeShellApplication {
          name = "docker-publish.sh";
          inherit text;
      };
      final-packages = { inherit docker-publish; } // publish-drvs // docker-packages;
      in {
        dockerPackages = builtins.attrValues docker-packages;
        packages = final-packages;
    };
  });
}
