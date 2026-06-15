{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    neru.url = "github:y3owk1n/neru";
    shared.url = "path:../../shared";
    claude-code.url = "github:sadjow/claude-code-nix";
    # Deliberately no nixpkgs.follows: its pkgsStatic/crane build is tested
    # against its own locked inputs, and matching them is what makes garnix
    # cache hits possible.
    bootstrap-mercury.url = "git+ssh://git@github.com/MercuryTechnologies/bootstrap-mercury.git";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
      nix-vscode-extensions,
      neru,
      shared,
      claude-code,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "nikita";
      hostname = "eule";
      homeDirectory = "/Users/${username}";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nix-vscode-extensions.overlays.default
          claude-code.overlays.default
        ];
      };
    in
    {
      homeConfigurations."${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit
            hostname
            system
            ;
          inputs = inputs // shared.inputs;
        };

        modules = [
          {
            home = {
              inherit homeDirectory username;
              stateVersion = "24.05";
            };

            my = {
              email = "nikita@mercury.com";
              p10k = ./dot-p10k.zsh;
            };

          }
          neru.homeManagerModules.default
          {
            nixpkgs.overlays = [ neru.overlays.default ];

            # TODO: move to separate module
            services.neru = {
              enable = true;
              config = ''
                [general]
                excluded_apps = ["com.github.wez.wezterm"]

                [recursive_grid]
                grid_cols = 3 
                grid_rows = 3
                keys = "rtyfghvbn"
              '';
            };
          }
          ./mercury.nix
          (shared.homeManagerModules.bat)
          (shared.homeManagerModules.btop)
          (shared.homeManagerModules.claude)
          (shared.homeManagerModules.direnv)
          (shared.homeManagerModules.git)
          (shared.homeManagerModules.home-manager)
          (shared.homeManagerModules.nvim)
          (shared.homeManagerModules.packages)
          (shared.homeManagerModules.tmux)
          (shared.homeManagerModules.vscode)
          (shared.homeManagerModules.lsd)
          (shared.homeManagerModules.wezterm)
          (shared.homeManagerModules.zsh)
        ];
      };
    };
}
