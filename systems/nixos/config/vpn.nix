{ pkgs, ... }: {
  office-vpn = {
    address = "192.168.5.98/32";
    privateKeyFile = "/home/nikita/.office-vpn/private.key";
  };
}
