{
  description = "some flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... } :
  let
    # TODO: change to your system, maybe aarch64-darwin on Mac
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    text = ''
    This is the first
    text'';
    more-text = ''
    More of the first
    text'';
    text0 = ''
    This is some other
    text'';
    my-result = pkgs.lib.evalModules {
      modules = [
        # To access pkgs from within the modules
        ({ config, ... }: { config._module.args = { inherit pkgs; }; })
        ./my-module.nix
        ./my-other-module.nix
        {text = text; text0 = text0;}
        {text = more-text;}
      ];
    };
    my-packages = builtins.trace (my-result.config.text + "===\n"+ my-result.config.text0) 
      (my-result.config.packages // my-result.config.packages1);
  in
  {
    packages.${system} = my-packages;
  };
}
