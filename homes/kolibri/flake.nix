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
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      hostname = "kolibri";
      email = "nikita.shumeiko@vitalbio.com";
      sessionVariables = {
        HYDRA_AARCH64_BUILDER = "hydra-aarch64.vital.company";
        HYDRA_X86_64_BUILDER = "hydra-x86-64.vital.company";
        # HYDRA_AARCH64_BUILDER = "nixbuild.vital.company";
        # HYDRA_X86_64_BUILDER = "nixbuild.vital.company";
        HYDRA_SSH_USER = "nikita";
        HYDRA_SSH_IDENTITY = "~/.ssh/id_ed25519";
        NIX_KEY = "~/nix-keys/kolibri.private.pem";
      };
      p10k = ./dot-p10k.zsh;
    in
    {
      homeConfigurations."nikita@kolibri" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit
            email
            hostname
            p10k
            sessionVariables
            system
            ;
          inputs = inputs // shared.inputs;
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
          (shared.homeManagerModules.tmux)
          (shared.homeManagerModules.vscode-server)
          (shared.homeManagerModules.lsd)
          (shared.homeManagerModules.zsh)
        ];
      };
    };
}
