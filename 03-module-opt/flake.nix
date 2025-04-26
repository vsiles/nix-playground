{
  description = "some flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... } :
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    my-result = pkgs.lib.evalModules {
      modules = [
        ({ config, ... }: { config._module.args = { inherit pkgs; }; })
        ./module.nix
        # { input = 42; }
      ];
    };
  in
  {
    packages = builtins.trace (toString my-result.config.out) {};
  };
}
