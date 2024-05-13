{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      builders-use-substitutes = true;
      secret-key-files = "/root/cache-priv-key.pem";

      trusted-users = [ "vin" ];
      substituters = [
      ];

      trusted-public-keys = [
      ];
    };
  };
}
