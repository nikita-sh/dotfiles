{
  description = "nikita's nixos configuration - built off of FrostPhoenix's";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    nix-gaming.url = "github:fufexan/nix-gaming";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:the-argus/spicetify-nix";
  };

  outputs = { home-manager, nixpkgs, spicetify-nix, self, ... }@inputs: {
    # TODO: this doesnt work - need to map these from imports to module format
    homeManagerModules = { 
      default = [
        ./bat
        ./lsd
        ./btop
        ./cava
        ./chatgpt-cli
        ./discord
        ./gaming
        ./git
        ./gtk
        ./hyprland
        ./kitty
        ./mako
        ./micro
        ./nvim
        ./package
        ./taskwarrior
        ./scripts
        ./slack
        ./swaylock
        ./waybar
        ./wofi
        ./spicetify
        ./zsh
        ./obsidian
      ];
    };
  };
}
