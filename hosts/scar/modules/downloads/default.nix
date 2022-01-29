{ pkgs, ... }:
{
  imports = [
    ./sonarr.nix
    ./torrent.nix
  ];

  users.groups.downloads.gid = 947;
  users.users.downloads = {
    isSystemUser = true;
    group = "downloads";
    uid = 947;
    home = "/var/lib/torrent";
    createHome = true;
  };

  users.users.taln.extraGroups = [ "downloads" ];

  networking.firewall.allowedTCPPorts = [
    80
  ];

  services.nginx.enable = true;

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad;
  };
}
