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
    in
    {
      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = my_modules;
        specialArgs = {
          inherit axumServer;
        };
      };
      packages.x86_64-linux.vm = self.nixosConfigurations.linuxVM.config.system.build.vm;

      nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = my_modules ++ [
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          { virtualisation.vmVariant.virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin; }
        ];
        specialArgs = {
          inherit axumServer;
        };
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;
    };
}
