{ config, pkgs, ... }:

let
  inherit (pkgs.lib) mkOption types;

  vpn-port = 51820;

in {
  options.office-vpn = {
    address = mkOption {
      type = types.str;
      description = ''
        This is the ip address for your user. It is found in the "Address" field of your conf file'';
      example = "192.168.5.4/32";
    };
    privateKeyFile = mkOption {
      type = types.path;
      description = ''
        Private key file to use when connecting to Office VPN. This file should have 600 permissions. 
        The file should only contain your private key value as defined by the \"PrivateKey\" value in your conf file.
      '';
    };
  };

  config.networking.firewall = {
    allowedUDPPorts =
      [ vpn-port ]; # Clients and peers can use the same port, see listenport
  };
  # Enable WireGuard
  config.networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ config.office-vpn.address ];
      listenPort =
        vpn-port; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = toString config.office-vpn.privateKeyFile;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "KWwb4c8l4gDtehAARxiE8+M27viZoRoMRtvKJpxjwmk=";

          # forward only particular subnets
          allowedIPs = [
            "192.168.5.1/32"
            config.office-vpn.address
            "192.168.100.0/22"
            "192.168.200.0/23"
            "172.16.0.0/16"
          ];

          # Set this to the server IP and port.
          endpoint = "72.142.27.218:${
              toString vpn-port
            }"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
