{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      ...
    }:
    {
      nixosConfigurations.mynah = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit (inputs) self nixpkgs;
          hostname = "mynah";
        };
        modules = [
          inputs.vscode-server.nixosModules.default
          nixos-wsl.nixosModules.wsl
          ../modules/network.nix
          ../modules/program.nix
          ../modules/services.nix
          ../modules/system.nix
          ../modules/security.nix
          {
            wsl = {
              enable = true;
              defaultUser = "nikita";
            };
            system.stateVersion = "24.05";
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
}
