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
        autocomplete = {
          enable = true;
        };
        languages = {
          haskell = { 
            enable = true;
            treesitter.enable = true;
            lsp.enable = true;
          };
          nix = {
            enable = true;
            extraDiagnostics.enable = true;
            format.enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          rust = {
            enable = true;
            crates = {
              enable = true;
              codeActions = true;
            };
            debugger.enable = true;
            lsp.enable = true;
          };
          sql.enable = true;
          ts.enable = true;
          python = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
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
    # build nvim
    packages.${system}.neovim = customNeovim;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
            ./work-nixos/configuration.nix
            home-manager.nixosModules.home-manager
        ];
      };

      morana = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./morana/morana.nix
          NixOS-WSL.nixosModules.wsl
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "nikita@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./work-nixos/home.nix];
      };

      "n@morana" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./morana/home.nix];
      };
    };
  };
}
