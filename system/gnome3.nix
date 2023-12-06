{ config, pkgs, ... }:
{
  environment.sessionVariables = {
    # QT_SCALE_FACTOR = "2";
  };

  environment.systemPackages = with pkgs; [
    blueman
    gnome3.gnome-tweaks
  ];

  services.xserver = {
    desktopManager.gnome = {
      enable = true;
    };
  };
}

