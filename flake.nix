{
  inputs = { };

  outputs = { self, ... }: {
    nixosModules = {
      default = self.nixosModules.bitmagnet;
      bitmagnet = import ./module;
    };
  };
}
