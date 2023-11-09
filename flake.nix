{
    description = "home manager";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	unstable.url = "github:nixos/nixpkgs-channels/nixos-unstable";
	trunk.url = "github:nixos/nixpkgs";
    };
    outputs = {nixpkgs, home-manager, ...}: {
        # For `nix run .` later
        defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

        homeConfigurations = {
            "nikita" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                pkgs = import nixpkgs { system = "x86_64-linux"; };

                modules = [ ./home.nix ]; # Defined later
            };
        };
    }; 
}

