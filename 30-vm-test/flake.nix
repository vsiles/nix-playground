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

          # Add system wide packages here
          environment.systemPackages = with pkgs; [
            neovim
            tree
            jq
          ];

          # Bash is the default shell in nix, no need to enable it
          programs.bash = {
            interactiveShellInit = ''
              echo "Hello, welcome to your nixos/linux VM!"
              echo "Use 'sudo poweroff' to turn the VM down and exit QEMU."
            '';
          };
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
          inherit axumServer;
        };
      };
      packages.x86_64-linux.vm = self.nixosConfigurations.linuxVM.config.system.build.vm;

      nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.base
          self.nixosModules.vm
          ./svc-module.nix
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          {
            virtualisation.vmVariant.virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          }
        ];
        specialArgs = {
          inherit axumServer;
        };
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;
    };
}
