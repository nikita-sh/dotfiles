{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    shared.url = "path:../../shared";
  };

  outputs =
    inputs@{
      self,
      nixvim,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      shared,
      ...
    }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
      hostname = "mynah";
    in
    {
      homeConfigurations."nikita@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs system hostname;
        };
        modules = [
          {
            home = {
              homeDirectory = "/home/nikita";
              stateVersion = "24.05";
              username = "nikita";
            };
          }
          (shared.homeManagerModules.bat)
          (shared.homeManagerModules.btop)
          (shared.homeManagerModules.claude)
          (shared.homeManagerModules.direnv)
          (shared.homeManagerModules.git)
          (shared.homeManagerModules.home-manager)
          (shared.homeManagerModules.nvim)
          (shared.homeManagerModules.packages)
          (shared.homeManagerModules.lsd)
          (shared.homeManagerModules.zsh)
        ];
      };

      formatter = pkgs.nixfmt;
    };
}
