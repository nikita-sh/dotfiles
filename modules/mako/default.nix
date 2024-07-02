{ config, pkgs, ... }: {
  services = {
    mako = {
      enable = true;
      font = "FiraCode Nerd Font 12";
      padding = "15";
      defaultTimeout = 5000;
      borderSize = 2;
      borderRadius = 5;
      backgroundColor = "#282828";
      borderColor = "#282828";
      progressColor = "over #ebdbb2";
      textColor = "#ebdbb2";
      icons = true;
      actions = true;
      extraConfig = ''
        text-alignment=center
        [urgency=high]
        border-color=#fab387
      '';
    };
  };
}
