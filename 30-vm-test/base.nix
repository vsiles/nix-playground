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
}
