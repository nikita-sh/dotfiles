{ pkgs, ... }: {
  services = {
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };

  programs.ssh.startAgent = true;
  systemd.user.services.add_ssh_keys = {
    script = ''
      eval `${pkgs.openssh}/bin/ssh-agent -s`
      ${pkgs.openssh}/bin/ssh-add $HOME/.ssh/key
    '';
    wantedBy = [ "default.target" ];
  };
}
