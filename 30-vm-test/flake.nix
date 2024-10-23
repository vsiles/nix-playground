{
  description = "Test VM";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    axumServer = { url = "path:./svc"; };
  };
  outputs =
    { self, nixpkgs, axumServer }:
    let
      axumPackage = axumServer.packages.x86_64-linux.default;
      test_command = axumServer.packages.x86_64-linux.test_command;
    in
    {
      nixosModules.base =
        { pkgs, ... }:
        {
          system.stateVersion = "24.05";

          # Configure networking
          networking.useDHCP = false;
          networking.interfaces.eth0.useDHCP = true;

          # Create user "test"
          services.getty.autologinUser = "test";
          users.users.test.isNormalUser = true;

          # Enable passwordless ‘sudo’ for the "test" user
          users.users.test.extraGroups = [ "wheel" ];
          security.sudo.wheelNeedsPassword = false;
        };

      nixosModules.vm =
        { ... }:
        {
          virtualisation.vmVariant.virtualisation.graphics = false;
        };

      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.base
          self.nixosModules.vm
          ./svc-module.nix
        ];
        specialArgs = {
          inherit test_command;
          axumServerPackage = axumPackage;
        };
      };
      packages.x86_64-linux.linuxVM = self.nixosConfigurations.linuxVM.config.system.build.vm;
    };
}
