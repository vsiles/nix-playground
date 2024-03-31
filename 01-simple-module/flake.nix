{
  description = "some flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... } :
  let my-result = nixpkgs.lib.evalModules {
    modules = [
      ./my-module.nix
      {msg = "hello"; x = 10; y = 1; }
      # use this instead to witness type checking error
      # {msg = "hello"; x = "10" ; y = 1; }
      # use this instead to witness missing argument
      # {msg = "hello";  y = 1; }
      # use this instead to witness unknown argument
      # {msg = "hello"; x = 10 ; y = 1; u = 10;}
    ];
  };
  in
  {
    # will trigger a warning but we don't care
    # !! don't forget to use `config` here
    my-result = my-result.config.z;
  };
}
