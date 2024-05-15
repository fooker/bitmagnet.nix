{ pkgs, lib, config, ... }:

with lib;

{
  options.bitmagnet.queue = {
    enable = mkEnableOption "Bitmagnet Queue service";

    tmdb = {
      enable = mkEnableOption "The Movie Database Integration";
      apiKeyFile = mkOption {
        type = types.nullOr types.path;
        description = ''
          Path to a file containing your TMDB API key.
        '';
        default = null;
      };
    };
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
          "TMDB_ENABLED=${toString config.bitmagnet.queue.tmdb.enable}"
        ];

        LoadCredential = [
          "tmdb_api_key:${config.bitmagnet.queue.tmdb.apiKeyFile}"
        ];

        ExecStart = pkgs.writeShellScript "bitmagnet-queue" ''
          ${optionalString (config.bitmagnet.queue.tmdb.apiKeyFile != null) ''
            export TMDB_API_KEY="$(cat "$CREDENTIALS_DIRECTORY/tmdb_api_key")"
          ''}

          exec ${pkgs.bitmagnet}/bin/bitmagnet worker run --keys=queue_server
        '';

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

