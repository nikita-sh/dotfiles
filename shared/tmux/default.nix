{ inputs, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    aggressiveResize = true;
    extraConfig = ''
      set -g default-command ${pkgs.zsh}/bin/zsh
    '';
  };
}
