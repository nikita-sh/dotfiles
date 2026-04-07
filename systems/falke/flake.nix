{
  description = "falke nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."falke" = nix-darwin.lib.darwinSystem {
        modules = [
          ./config.nix
          ./user.nix
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."falke".pkgs;
    };
}
