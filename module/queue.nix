{ pkgs, lib, config, ... }:

with lib;

{
  options.bitmagnet.queue = {
    enable = mkEnableOption "Bitmagnet Queue service";
  };

  config = mkIf config.bitmagnet.queue.enable {
    systemd.services."bitmagnet-queue" = {
      description = "Bitmagnet Queue";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Environment = [
          "POSTGRES_USER=bitmagnet"
          "POSTGRES_HOST=${config.bitmagnet.vpn.peers.${config.bitmagnet.database.host}.address}"
          "POSTGRES_NAME=bitmagnet"
        ];

        ExecStart = "${pkgs.bitmagnet}/bin/bitmagnet worker run --keys=queue_server";

        Restart = "always";
        RestartSec = "10s";

        TimeoutStartSec = "infinity";

        DynamicUser = true;

        RuntimeDirectory = "bitmagnet/queue";
        WorkingDirectory = "%S/bitmagnet/queue";

        StateDirectory = "bitmagnet/queue";
        StateDirectoryMode = "0700";
      };
    };
  };
}

