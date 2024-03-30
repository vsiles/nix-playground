{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ config, self', pkgs, ... }: {
    options = {
      rustConfiguration = mkOption {
        description = "Information about a Rust project";
        type = types.submodule {
          options = {
            manifest-path = mkOption {
              type = types.path;
              description = "Path to the Cargo.toml manifest file";
            };
            is-workspace = mkOption {
              readOnly = true;
              type = types.bool;
              description = "Is the project a workspace or not ?";
            };
            workspace-name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "unnamed-project";
              description = "Override since [workspace] does not support `name`";
            };
            workspace-version = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "0.0.0";
              description = "Override since [workspace] does not support `version`";
            };
            name = lib.mkOption {
              readOnly = true;
              type = lib.types.str;
              description = "Name of the package";
            };
            version = lib.mkOption {
              readOnly = true;
              type = lib.types.str;
              description = "Version of the package";
            };
            members = lib.mkOption {
              readOnly = true;
              type = lib.types.listOf lib.types.str;
              description = "List of the members of the workspace, if relevant";
            };
          };
          config =
            let
              manifest = (lib.importTOML config.rustConfiguration.manifest-path);
              get = default: key: set: if builtins.hasAttr key set then set.${key} else default;
              get-package-info = package: {
                name = get config.rustConfiguration.workspace-name "name" package;
                version = get config.rustConfiguration.workspace-version "version" package;
              };
              members = if builtins.hasAttr "workspace" manifest then manifest.workspace.members else [];
              package = if builtins.hasAttr "package" manifest
              then get-package-info manifest.package 
              else (
                if builtins.hasAttr "workspace" manifest
                then (
                  if builtins.hasAttr "package" manifest.workspace
                  then get-package-info manifest.workspace.package
                  else get-package-info {}
                  ) else get-package-info {}
                  );
            in {
              inherit (package) name version;
              inherit members;
              is-workspace = builtins.hasAttr "workspace" manifest;
          };
        };
      };
    };
  });
}
