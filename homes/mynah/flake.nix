{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shared.url = "path:../../shared";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
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
