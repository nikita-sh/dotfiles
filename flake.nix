{
  description = "kelp";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # neovim
    neovim-flake.url = "github:nikita-sh/neovim-flake";

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
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    configModule = {
        config.vim.theme.enable = true;
    };
    customNeovim = neovim-flake.lib.neovimConfiguration {
	modules = [configModule];
	inherit pkgs;
    };
  in {
    packages.${system}.neovim = customNeovim;
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'

    environment.systemPackages = with pkgs; [
        neovim-flake.defaultPackage.${pkgs.system} 
    ];
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
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "nikita@nixos" = home-manager.lib.homeManagerConfiguration {
        # pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./home.nix];
      };
    };
  };
}
