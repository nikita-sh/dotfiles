{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./cliamp.nix { })
  ];
}
