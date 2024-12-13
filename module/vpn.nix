{ pkgs
, config
, lib
, ...
}:

with lib;

let
  cfg = config.bitmagnet;

in {
  options.bitmagnet.vpn = {
    enable = mkEnableOption "Bitmagnet VPN service";

    name = mkOption {
      type = types.enum (attrNames cfg.vpn.peers);
      default = config.networking.hostName;
      description = ''
        Name of the local peer.
      '';
    };

    netdev = mkOption {
      type = types.str;
      default = "bitmagnet";
      description = ''
        Name of the VPN networkd device.
      '';
    };
  
    privateKeyFile = mkOption {
      type = types.str;
      description = ''
        Path to private key file.
      '';
      default = "/run/keys/bitmagnet/vpn/privatekey";
    };

    self = mkOption {
      type = types.anything;
      internal = true;
      readOnly = true;
      default = cfg.vpn.peers.${cfg.vpn.name};
      description = ''
        Our own peer declaration.
      '';
    };

    peers = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            readOnly = true;
            default = name;
            description = ''
              Name of the peer.
            '';
          };

          endpoint = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                address = mkOption {
                  type = types.str;
                  description = ''
                    Remote VPN endpoint address.
                  '';
                };
                port= mkOption {
                  type = types.ints.u16;
                  description = ''
                    Remote VPN endpoint port.
                  '';
                };
              };
            });
          };

          publicKey = mkOption {
            type = types.str;
            description = ''
              Public Key of the remote peer.
            '';
          };

          address = mkOption {
            type = types.str;
            description = ''
              Remote IP address.
            '';
          };

          maintainer = mkOption {
            type = types.str;
            description = ''
              Maintainer of the peer.
            '';
          };
        };
      }));
      description = ''
        VPN peers
      '';
    };
  };

  config = mkIf (cfg.vpn.enable) {
    systemd.network = {
      netdevs."50-bitmagnet" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1280";
          Name = cfg.vpn.netdev;
        };
        
        wireguardConfig = {
          PrivateKeyFile = cfg.vpn.privateKeyFile;
          ListenPort = mkIf (cfg.vpn.self.endpoint != null) cfg.vpn.self.endpoint.port;
        };

        wireguardPeers = mapAttrsToList
          (_: peer: {
            AllowedIPs = [ peer.address ];
            Endpoint = mkIf (peer.endpoint != null) "${peer.endpoint.address}:${toString peer.endpoint.port}";
            PublicKey = peer.publicKey;
          })
          (filterAttrs (name: _: name != cfg.vpn.name) cfg.vpn.peers);
      };

      networks."60-bitmagnet" = {
        matchConfig.Name = cfg.vpn.netdev;
        
        address = [
          "${cfg.vpn.self.address}/24"
        ];

        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };
}

