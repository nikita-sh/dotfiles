{ pkgs, ... }:
{
  networking = {
    hostName = "mynah";
  };

  services = {
    dbus.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };

  programs = {
    ssh.startAgent = true;
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nix = {
    settings = {
      download-buffer-size = "100000000";
      trusted-users = [ "nikita" ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    distributedBuilds = true;
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
