{
  inputs = {
    nixpkgs.url = "nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations.kolibri = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          inherit (inputs) self nixpkgs;
          hostname = "kolibri";
        };
        modules = [
          ./hardware.nix
          ./config.nix
          ../modules/office-vpn.nix
          ../modules/software-workstation.nix
          ../modules/probe-rs.nix
          ../modules/vpn.nix
          ../modules/user.nix
        ];
      };
    };
}
