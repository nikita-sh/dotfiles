{ pkgs, lib, config, inputs, ... }: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      datestr = "";
      screenshots = true;

      indicator = true;
      indicator-radius = 120;
      indicator-thickness = 16;

      effect-blur = "9x9";
      effect-vignette = "0.5:0.5";

      color = "1e1e2e";
      bs-hl-color = "f5e0dc";
      caps-lock-bs-hl-color = "f5e0dc";
      caps-lock-key-hl-color = "a6e3a1";
      ring-color = "32302f";
      ring-clear-color = "8ec07c";
      ring-caps-lock-color = "fab387";
      ring-ver-color = "83a598";
      ring-wrong-color = "fb4934";
      text-color = "fbf1c7";
      text-clear-color = "f5e0dc";
      text-caps-lock-color = "fab387";
      text-ver-color = "89b4fa";
      text-wrong-color = "eba0ac";

      inside-color = "32302f";
      inside-clear-color = "8ec07c";
      inside-caps-lock-color = "00000000";
      inside-ver-color = "83a598";
      inside-wrong-color = "fb4934";
      key-hl-color = "d3869b";
      layout-bg-color = "00000000";
      layout-border-color = "00000000";
      layout-text-color = "cdd6f4";
      line-color = "32302f";
      line-clear-color = "8ec07c";
      line-caps-lock-color = "00000000";
      line-ver-color = "83a598";
      line-wrong-color = "fb4934";
      separator-color = "00000000";
    };
  };
  # services.swayidle = {
  #   enable = true;
  #   events = [
  #     {
  #       event = "before-sleep";
  #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
  #     }
  #     {
  #       event = "lock";
  #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
  #     }
  #   ];
  #   timeouts = [
  #     {
  #       timeout = 90;
  #       command = "swaylock";
  #     }
  #     {
  #       timeout = 300;
  #       command = "systemctl suspend";
  #     }
  #     {
  #       timeout = 180;
  #       command = "systemctl suspend";
  #       # command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
  #       # resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
  #     }
  #   ];
  # };

  # systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
}
