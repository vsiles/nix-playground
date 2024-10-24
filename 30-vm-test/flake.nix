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
      darwin-pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      recursiveUpdate = darwin-pkgs.lib.recursiveUpdate;
      linux-pkgs = nixpkgs.legacyPackages.aarch64-linux;
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
    in
    {
      nixosConfigurations.linuxVM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixosModules.base
          nixosModules.vm
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
          nixosModules.base
          nixosModules.vm
          ./svc-module.nix
          # This VM will use the host /nix/store thus avoid 'Exec format error'
          {
            virtualisation.vmVariant.virtualisation.host.pkgs = darwin-pkgs;
          }
        ];
        specialArgs = {
          inherit axumServer;
        };
      };
      packages.aarch64-darwin.vm = self.nixosConfigurations.darwinVM.config.system.build.vm;

      # Testing nixos tests
      # https://nix.dev/tutorials/nixos/integration-testing-using-virtual-machines.html
      # 
      packages.aarch64-darwin.test = darwin-pkgs.testers.runNixOSTest {
        name = "My simple test";
        nodes.machine = { config, pkgs, ... }@inputs: 
          recursiveUpdate 
        (nixosModules.base inputs) {

          users.users.alice = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              tree
            ];
          };

          system.stateVersion = "24.05";
        };
        testScript = ''
          machine.wait_for_unit("default.target")

          machine.succeed("su -- alice -c 'which tree'")
          machine.fail("su -- alice -c  'which hx'")
          # uncomment to see a test failure
          # machine.succeed("su -- alice -c  'which hx'")

          # Waiting for the service
          machine.succeed("systemctl is-active axum-echo-server")

          # Calling GET
          get_response = machine.succeed("${linux-pkgs.curl}/bin/curl http://localhost:3000 -X GET")
          assert get_response == "Hello, You!"

        '';
      };
    };
}
