{ pkgs ? import (fetchTarball {
  url =
    "https://github.com/NixOS/nixpkgs/archive/4fe8d07066f6ea82cda2b0c9ae7aee59b2d241b3.tar.gz";
  sha256 = "sha256:06jzngg5jm1f81sc4xfskvvgjy5bblz51xpl788mnps1wrkykfhp";
}) { } }:
pkgs.stdenv.mkDerivation {
  pname = "gruvbox-gtk";
  version = "2024-03-11";

  src = pkgs.fetchgit {
    url = "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme";
    rev = "c0b7fb501938241a3b6b5734f8cb1f0982edc6b4";
    sha256 = "wnGjqqvOd23HSnX3OzH0Lq1wUBHPb1U1wy43zP6pUd8=";
  };

  propagatedUserEnvPkgs = [ pkgs.gtk-engine-murrine ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share
    cp -r $src/themes $out/share/
    cp -r $src/icons $out/share/
  '';

  meta = with pkgs.lib; {
    description = "Gruvbox theme for GTK 2/3";
    homepage = "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.vanilla ];
  };
}
