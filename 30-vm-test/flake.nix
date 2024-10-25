{
  description = "Test VM";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    axumServer = {
      url = "path:./svc";
    };
    openglStuff = {
      url = "path:./vsiles-gl";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      axumServer,
      openglStuff,
    }:
    let
      my_modules = [
        ./base.nix
        ./vm.nix
        ./svc-module.nix
        ./opengl-module.nix
      ];
      openglStuffOverlay =
        final: prev:
        {

          vsiles-gl = prev.vsiles-gl.overrideAttrs (oldAttrs: {
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.mesa.llvmpipeHook ];
          });
        };
      overlayApply =
        pkgs:
        ((pkgs.extend axumServer.overlays.default).extend openglStuff.overlays.default).extend openglStuffOverlay;
      linux-pkgs = overlayApply nixpkgs.legacyPackages.x86_64-linux;
      darwin-pkgs = overlayApply nixpkgs.legacyPackages.aarch64-darwin;
      linux-guest-pkgs = overlayApply nixpkgs.legacyPackages.aarch64-linux;
      myOverlays = [
        axumServer.overlays.default
        openglStuff.overlays.default
        openglStuffOverlay
      ];
      tester =
        {
          host-pkgs,
          guest-pkgs,
          name,
        }:
        host-pkgs.testers.runNixOSTest {
          inherit name;

          nodes.machine =
            { config, pkgs, ... }:
            {
              imports = my_modules;

              users.users.alice = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                packages = [ pkgs.tree ];
              };
              system.stateVersion = "24.05";
            };
          testScript = ''
            machine.wait_for_unit("default.target");
            machine.succeed("su -- alice -c 'which tree'")
            machine.succeed("su -- test -c 'which jq'")
            result = machine.succeed("ps aux | grep svc")
            print(result)
            # Testing GET
            result = machine.succeed("${guest-pkgs.curl}/bin/curl -X GET http://localhost:3000")
            assert result == "Hello, You!"

          '';
        };
    in
    {
      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = myOverlays; }
        ] ++ my_modules;
      };
      packages.x86_64-linux.vm = self.nixosConfigurations.linuxVM.config.system.build.vm;
      packages.x86_64-linux.test = tester {
        host-pkgs = linux-pkgs;
        guest-pkgs = linux-pkgs;
        name = "VM Test (linux)";
      };

      nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          { nixpkgs.overlays = myOverlays; }
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          { virtualisation.vmVariant.virtualisation.host.pkgs = darwin-pkgs; }
        ] ++ my_modules;
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;
      packages.aarch64-darwin.test = tester {
        host-pkgs = darwin-pkgs;
        guest-pkgs = linux-guest-pkgs;
        name = "VM Test (darwin)";
      };
    };
}
