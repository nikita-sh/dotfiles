{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    omp.url = "github:can1357/oh-my-pi";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      transformModulePaths =
        paths:
        builtins.listToAttrs (
          map (path: {
            name = builtins.baseNameOf path;
            value = import path;
          }) paths
        );
    in
    {
      # FIXME: this is kind of icky
      inherit inputs;

      homeManagerModules = transformModulePaths [
        ./agents
        ./omp
        ./bat
        ./btop
        ./cliamp
        ./direnv
        ./git
        ./home-manager
        ./jj
        ./lsd
        ./meat
        ./nvim
        ./packages
        ./tmux
        ./vscode
        ./vscode-server
        ./wezterm
        ./zed
        ./zsh
      ];
    };
}
