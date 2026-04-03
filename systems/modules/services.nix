{ pkgs, ... }:
{
  services = {
    # gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
      ensureUsers = [
        {
          name = "nikita";
          ensureClauses.superuser = true;
        }
      ];
      ensureDatabases = [
        "conductor"
      ];
      # settings = {
      #   port = 10004;
      # };
    };
  };

  programs.ssh.startAgent = true;
  # systemd.user.services.add_ssh_keys = {
  #   script = ''
  #     eval `${pkgs.openssh}/bin/ssh-agent -s`
  #     ${pkgs.openssh}/bin/ssh-add $HOME/.ssh/key
  #   '';
  #   wantedBy = [ "default.target" ];
  # };
}
