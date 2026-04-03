{ ... }:
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    displayManager.autoLogin = {
      enable = true;
    };
    libinput = {
      enable = true;
    };
  };
  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
