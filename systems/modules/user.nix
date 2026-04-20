{ pkgs, ... }:
{
  users.users.nikita = {
    isNormalUser = true;
    home = "/home/nikita";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh; 
  };
}
