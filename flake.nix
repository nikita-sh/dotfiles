{
  description = "kelp";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # neovim
    neovim-flake.url = "github:nikita-sh/neovim-flake";

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    neovim-flake,
    self,
    nixpkgs,
    home-manager,
    NixOS-WSL,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    configModule = {
        config.vim = {
            theme.enable = true;
            languages = {
                nix.enable = true;
                rust.enable = true;
                sql.enable = true;
                ts.enable = true;
                python.enable = true;
                markdown.enable = true;
            };
            filetree = {
                nvimTreeLua = {
                    enable = true;
                    openTreeOnNewTab = true;
                    disableNetRW = true;
                };
            };
            git = {
                enable = true;
                gitsigns.enable = true;
            };
            telescope = {
                enable = true;
            };
            autopairs = {
                enable = true;
            };
            statusline = {
                lualine = {
                    enable = true;
                };
            };
            visuals = {
                enable = true;
                cursorWordline.enable = true;
                indentBlankline = {
                    enable = true;
                    eolChar = null;
                    fillChar = null;
                };
            };
        };
    };

    customNeovim = neovim-flake.lib.neovimConfiguration {
        modules = [configModule];
        inherit pkgs;
    };
  in {
    packages.${system}.neovim = customNeovim;
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    
    nixosConfigurations = {
      # FIXME replace with your hostname
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
                # home-manager.useGlobalPkgs = true;
                # home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {inherit inputs outputs;};
                home-manager.users.nikita = import ./home.nix;
            }
        ];
      };
      morana = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./morana/morana.nix
          NixOS-WSL.nixosModules.wsl
          #home-manger.nixosModules.home-manager
          #{
                #  home-manager.extraSpecialArgs = {inherit inputs outputs;};
          #  home-manager.users.n = import ./morana/home.nix;
          #}
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "nikita@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./home.nix];
      };
      "n@morana" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./morana/home.nix];
      };
    };
  };
}
