{ config, pkgs, ... }:
    let
      axumServerPackage = pkgs.svc;
      test_command = pkgs.test_command;
    in
{
  systemd.services.axum-echo-server = {
    enable = true;
    description = "Axum Echo Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${axumServerPackage}/bin/svc";
      Restart = "always";
      RestartSec = 5;
    };
  };
  environment.systemPackages = [
    test_command
    axumServerPackage
  ];
}

