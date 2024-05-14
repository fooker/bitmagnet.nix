{ pkgs, lib, config, ... }:

with lib;

{
  options.bitmagnet.web = {
    enable = mkEnableOption "Bitmagnet Web Interface service";
  };

  config = mkIf config.bitmagnet.web.enable {
    systemd.services."bitmagnet-web" = {
      description = "Bitmagnet Web Interface";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Environment = [
          "POSTGRES_USER=bitmagnet"
          "POSTGRES_HOST=${config.bitmagnet.vpn.peers.${config.bitmagnet.database.host}.address}"
          "POSTGRES_NAME=bitmagnet"
        ];

        ExecStart = "${pkgs.bitmagnet}/bin/bitmagnet worker run --keys=http_server";

        Restart = "always";
        RestartSec = "10s";

        TimeoutStartSec = "infinity";

        DynamicUser = true;

        RuntimeDirectory = "bitmagnet/web";
        WorkingDirectory = "%S/bitmagnet/web";

        StateDirectory = "bitmagnet/web";
        StateDirectoryMode = "0700";
      };
    };
  };
}

