{
  pkgs,
  ...
}:
pkgs.buildGoModule {
  pname = "meat";
  version = "0-unstable-2026-08-04";

  src = pkgs.fetchFromGitHub {
    owner = "boldsoftware";
    repo = "meat";
    rev = "f39f41dfe7b5b37a12b35fdfbaecc7e779855bd3";
    hash = "sha256-fj04sdMiwPxh4F+kBpF5c+YYeKnKCDD9dsIgwAGPoK4=";
  };

  # The module has no external dependencies, so there is nothing to vendor.
  vendorHash = null;

  subPackages = [ "cmd/meat" ];

  meta = {
    description = "Abridge a code diff into a reading diff";
    homepage = "https://github.com/boldsoftware/meat";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "meat";
  };
}
