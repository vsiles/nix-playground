 { config, pkgs, ... }:
    let
      vsiles-gl = pkgs.vsiles-gl;
      vsiles-setup = pkgs.writeShellScriptBin "vsiles-setup" ''
        set -x
        Xvfb :99 -ac -noreset +extension GLX +extension RANDR +extension RENDER +render -screen 0 3840x2160x24 -nolisten tcp -nolisten unix
      '';
    in
{
  environment.systemPackages = [
    vsiles-gl
    pkgs.glxinfo
    pkgs.xorg.xorgserver
    vsiles-setup
  ];
}

# DISPLAY=:99 glxinfox

