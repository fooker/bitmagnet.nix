{ pkgs, inputs, ... }:

let 
  peers = import inputs.bitmagnet-peers;

in
{
  imports = [
    "${inputs.bitmagnet}/module"
  ];

  bitmagnet = {
    enable = true;

    vpn = {
      privateKeyFile = "/path/to/private/key";
      inherit peers;
    };

    database = {
      host = "raketensilo";

      server.enable = true;
    };

    crawler.enable = true;
    queue.enable = true;
    web.enable = true;
  };
}

