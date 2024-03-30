{ lib, config, ... } : {
  options = {
    manifest-path = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cargo.toml manifest file";
    };
    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "unnamed-workspace";
      description =
        "Name of the package, if not present in the Cargo.toml file (e.g. for workspaces)";
    };
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "0.1.0";
      description =
        "Version of the package, if not present in the Cargo.toml file (e.g. for workspaces)";
    };
    package-info.name = lib.mkOption {
      readOnly = true;
      type = lib.types.str;
      description = "Name of the package";
    };

    package-info.version = lib.mkOption {
      type = lib.types.str;
      description = "Version of the package";
    };


    package-info.members = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of the members of the workspace, if relevant";
    };
  };

  config = 
  let
    manifest = (lib.importTOML config.manifest-path);
    get = default: key: set: if builtins.hasAttr key set then set.${key} else default;
    get-package-info = package: {
      name = get config.name "name" package;
      version = get config.version "version" package;
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
        )
        else get-package-info {}
        );
  in {
    package-info = {
      inherit (package) name version;
      inherit members;
    };
  };
}
