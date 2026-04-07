{ ... }:
{
  users.users.nikita = {
    isNormalUser = true;
    home = "/home/nikita";
    extraGroups = [ "wheel" ];
  };
}
