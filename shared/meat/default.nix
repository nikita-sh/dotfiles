{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./meat.nix { })
  ];
}
