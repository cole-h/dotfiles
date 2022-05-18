{ ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = false;

  systemd.network.wait-online.ignoredInterfaces = [
    "wg0"
    "tailscale0"
  ];

  networking.hostId = "1bb11552"; # Required for ZFS.
  networking.nameservers = [
    "192.168.1.25"
    "1.1.1.1"
    "8.8.8.8"
    # "100.100.100.100" # tailscale
  ];
  # networking.search = [ "example.com.beta.tailscale.net" ];
  networking.defaultGateway = "192.168.1.1";
  networking.interfaces.enp6s0.ipv4 = {
    addresses = [
      {
        address = "192.168.1.23";
        prefixLength = 24;
      }
    ];
  };

  networking.firewall.extraCommands = ''
    iptables -I FORWARD -i virbr0 -j ACCEPT
  '';

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22000 # syncthing
    4646 # XIV QuickLauncher
  ];

  networking.firewall.allowedUDPPorts = [
    21027 # syncthing
    51821
  ];
}
