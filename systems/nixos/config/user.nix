{ pkgs, ... }: {
  users.users.nikita = {
    isNormalUser = true;
    description = "nikita";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
    shell = pkgs.zsh;
  };
  nix.settings.allowed-users = [ "nikita" ];
}
