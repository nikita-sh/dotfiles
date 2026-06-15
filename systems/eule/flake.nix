{
  description = "eule nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    {
      darwinConfigurations."eule" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self inputs; };
        modules = [
          ./config.nix
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."eule".pkgs;
    };
}
