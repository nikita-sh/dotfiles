{ config, pkgs, ... }:

{
  home.packages = [ pkgs.feh ];

  systemd.user.services.feh-background = {
    Unit = {
      Description = "Background image";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.feh}/bin/feh --bg-scale ${config.home.homeDirectory}/.config/background.jpg";
    };
  };
}
