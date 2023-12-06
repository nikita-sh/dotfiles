{ config, pkgs, ... }:
{
  environment.sessionVariables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  environment.systemPackages = with pkgs; [
    blueman
    dmenu
    (polybar.override { pulseSupport = true; })
    scrot
    xclip
  ];

  services.xserver = {
    displayManager.defaultSession = "none+xmonad";

    displayManager.sddm = {
      enable = true;
      enableHidpi = true;
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = p: with p; [
        xmonad-contrib
        xmonad-extras
        xmonad
      ];
    };
  };
}

