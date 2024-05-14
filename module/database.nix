{ pkgs, lib, config, ... }:

with lib;

{
  options.bitmagnet.database = {
    server = {
      enable = mkEnableOption "Bitmagnet Crawler service";
    };

    host = mkOption {
      type = types.enum (attrNames config.bitmagnet.vpn.peers);
      description = ''
        Name of the peer hosting the database.
      '';
    };
  };

  config = mkIf config.bitmagnet.database.server.enable {
    services.postgresql = {
      enable = true;
      
      enableTCPIP = true;
      
      ensureUsers = [ {
        name = "bitmagnet";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      } ];
      ensureDatabases = [ "bitmagnet" ];

      authentication = ''
        # TYPE  DATABASE    USER        ADDRESS                                   METHOD
        host    bitmagnet   bitmagnet   ${config.bitmagnet.vpn.self.address}/24   trust
        host    bitmagnet   bitmagnet   127.0.0.1/8                               trust
      '';
    };
  };
}

