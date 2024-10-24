{
  description = "Test VM";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    axumServer = {
      url = "path:./svc";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      axumServer,
    }:
    let
      my_modules = [
        ./base.nix
        ./vm.nix
        ./svc-module.nix
      ];
      linux-pkgs = nixpkgs.legacyPackages.x86_64-linux.extend axumServer.overlays.default;
      darwin-pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ axumServer.overlays.default ]; }
        ] ++ my_modules;
      };
      packages.x86_64-linux.vm = self.nixosConfigurations.linuxVM.config.system.build.vm;
      packages.x86_64-linux.test = linux-pkgs.testers.runNixOSTest {
        name = "VM Test (linux)";

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
          result = machine.succeed("${linux-pkgs.curl}/bin/curl http://localhost:3000 -X GET")
          assert result == "Hello, You!"
          
        '';
      };

      nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          # TODO: Maybe overlay darwin-pkgs too / instead ?
          { nixpkgs.overlays = [ axumServer.overlays.default ]; }
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          { virtualisation.vmVariant.virtualisation.host.pkgs = darwin-pkgs; }
        ] ++ my_modules;
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;
    };
}
