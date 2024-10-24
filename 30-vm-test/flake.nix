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
      linux-pkgs = nixpkgs.legacyPackages.x86_64-linux;
      darwin-pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      specialArgs = {
        inherit axumServer;
      };
    in
    {
      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = my_modules;
        inherit specialArgs;
      };
      packages.x86_64-linux.vm = self.nixosConfigurations.linuxVM.config.system.build.vm;
      packages.x86_64-linux.test = linux-pkgs.testers.runNixOSTest {
        name = "VM Test (linux)";
        inherit specialArgs;

        nodes.machine =
          { config, pkgs, ... }:
          {
            imports = [
              ./base.nix
              ./vm.nix
              ./svc-module.nix
            ];

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
        '';
      };

      nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = my_modules ++ [
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          { virtualisation.vmVariant.virtualisation.host.pkgs = darwin-pkgs; }
        ];
        specialArgs = {
          inherit axumServer;
        };
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;
    };
}
