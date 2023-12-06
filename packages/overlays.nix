{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      fiji = self.callPackage ./fiji.nix {};
      ovftool = self.callPackage ./ovftool.nix {};
    })
  ];
}
