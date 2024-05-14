{ pkgs
, config
, lib
, ...
}:

with lib;

{
  options.bitmagnet = {
    enable = mkEnableOption "Bitmagnet Torrent Index";
  };

  imports = [
    ./vpn.nix
    ./crawler.nix
    ./queue.nix
    ./web.nix
    ./database.nix
  ];
}
