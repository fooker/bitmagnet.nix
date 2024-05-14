{ pkgs, lib, config, ... }:

with lib;

{
  options.bitmagnet.crawler = {
    enable = mkEnableOption "Bitmagnet Crawler service";
  };

  config = mkIf config.bitmagnet.crawler.enable {
    systemd.services."bitmagnet-crawler" = {
      description = "Bitmagnet Crawler";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Environment = [
          "POSTGRES_USER=bitmagnet"
          "POSTGRES_HOST=${config.bitmagnet.vpn.peers.${config.bitmagnet.database.host}.address}"
          "POSTGRES_NAME=bitmagnet"
        ];

        ExecStart = "${pkgs.bitmagnet}/bin/bitmagnet worker run --keys=dht_crawler";

        Restart = "always";
        RestartSec = "10s";

        TimeoutStartSec = "infinity";

        DynamicUser = true;

        RuntimeDirectory = "bitmagnet/crawler";
        WorkingDirectory = "%S/bitmagnet/crawler";

        StateDirectory = "bitmagnet/crawler";
        StateDirectoryMode = "0700";
      };
    };
  };
}

