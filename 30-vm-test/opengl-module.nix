 { config, pkgs, ... }:
    let
      vsiles-gl = pkgs.vsiles-gl;
    in
{
  environment.systemPackages = [
    vsiles-gl
  ];
}

