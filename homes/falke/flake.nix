{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    shared.url = "path:../../shared";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
      nix-vscode-extensions,
      shared,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "nikita";
      hostname = "falke";
      homeDirectory = "/Users/${username}";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nix-vscode-extensions.overlays.default
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
              sessionVariables = {
                HYDRA_AARCH64_BUILDER = "hydra-aarch64.vital.company";
                HYDRA_X86_64_BUILDER = "hydra-x86-64.vital.company";
                # HYDRA_AARCH64_BUILDER = "nixbuild.vital.company";
                # HYDRA_X86_64_BUILDER = "nixbuild.vital.company";
                HYDRA_SSH_USER = "${username}";
                HYDRA_SSH_IDENTITY = "${homeDirectory + "/.ssh/id_ed25519"}";
                NIX_KEY = "${homeDirectory + "/nix-keys/falke.private.pem"}";
              };

              email = "nikita.shumeiko@vitalbio.com";
              p10k = ./dot-p10k.zsh;
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
          (shared.homeManagerModules.tmux)
          (shared.homeManagerModules.vscode)
          (shared.homeManagerModules.lsd)
          (shared.homeManagerModules.wezterm)
          (shared.homeManagerModules.zsh)
        ];
      };
    };
}
