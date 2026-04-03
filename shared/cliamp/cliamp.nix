{
  pkgs,
  ...
}:
pkgs.buildGoModule {
  pname = "cliamp";
  name = "cliamp";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    alsa-lib
    flac
    libvorbis
    oggvideotools
  ];

  src = pkgs.fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    rev = "13c6ffff8d245e023b5b5d06674c28a5763ed832";
    hash = "sha256-b14rcfn8R18w7QuhOv24G7xvrvo8eUI62G+Ac2fpOhw=";
  };

  vendorHash = "sha256-UMDCpfSGfvJmI+sImaFzgZpLNaLMgEnmGCqERwPokHM=";
}
